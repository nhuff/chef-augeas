require 'chef/provider'
require 'chef/util/diff'
require 'chef/log'
require 'strscan'
require 'set'

class Chef
  class Provider
    class Augeas < Chef::Provider

      def initialize(new_resource,run_context=nil)
        super(new_resource,run_context)
        require 'augeas'
      end

      def load_current_resource
        true
      end

      def action_run
        aug = ::Augeas::open(nil,nil,::Augeas::SAVE_NEWFILE)
        changes = parse_changes(@new_resource.changes())
        if need_run?(aug,@new_resource.run_if,changes)
          execute_changes(aug,changes)
        end
        aug.close()
      end

      def need_run?(aug,run_if,changes)
        if run_if
          o_i = check_guard(aug,parse_args(run_if))
        else
          o_i = true
        end
        i_s = in_sync?(aug,changes)
        return (o_i and !i_s)
      end

      def execute_changes(aug,changes)
        aug.set('/augeas/save','overwrite')
        aug.load
        changes.map{|x| execute_change(aug,x)}
        result = aug.save
      end

      def in_sync?(aug,changes)
        changes.map{|x| execute_change(aug,x)}
        aug.save
        saved_events = aug.match('/augeas/events/saved')
        if saved_events.size > 0
          saved_files  = Set.new(saved_events.map{|x| aug.get(x).sub(/^\/files/,'')})
          saved_files.map{|x| ::File.delete(x+".augnew")}
          return false
        end
        return true
      end

      def check_guard(aug,guard)
        case guard[0]
        when 'get'
          return process_get(aug,guard)
        when 'match'
          return process_match(aug,guard)
        else
          raise ArgumentError,"#{guard[0]} is not a valid matcher in run_if"
        end
      end

      def process_match(aug,guard)
        if guard.length < 4
          raise ArgumentError,"match requires at least 3 arguments" 
        end

        ret = false
        path,verb = guard[1],guard[2]
        matches = aug.match(path) || []
        case verb
        when 'size'
          if guard.length != 5
            raise ArgumentError,"match with size requires 4 args"
          end
          comp = guard[3]
          val  = guard[4].to_i
          if comp == '!='
            ret = !matches.size.send(:==,val)
          else
            ret = matches.size.send(comp,val)
          end
        when 'include'
          ret = matches.include?(guard[3])
        when 'not_include'
          ret = !matches.include?(guard[3])
        when '=='
          val = eval guard[3]
          ret = (matches == val)
        when '!='
          val = eval guard[3]
          ret = !(matches == val)
        else
          raise ArgumentError,"verb #{verb} not supported by match" 
        end
        return ret
      end

      def process_get(aug,guard)
        raise ArgumentError,"get requires 3 arguments" if guard.length != 4
        ret = false
        path,comp,value = guard[1],guard[2],guard[3]
        unless ['>','<','<=','>=','==','!=','=~'].include?(comp)
          raise ArgumentError,"Uknown comparator #{comp}"
        end
        cur = aug.get(path) || ''

        case comp
        when '>','<','<=','>='
          if is_numeric?(cur) and is_numeric?(value)
            curf = cur.to_f
            valf = value.to_f
            ret = valf.send(comp,curf)
          else
            ret = value.send(comp,cur)
          end
        when '!='
          ret = (value != cur)
        when '=~'
          ret = (cur =~ Regexp.new(value))
        else
          ret = value.send(comp,cur)
        end

        return ret
      end

      def is_numeric?(s)
        case s
        when Fixnum
          true
        when String
          s.match(/\A[+-]?\d+?(\.\d+)?\Z/n) == nil ? false : true
        else
          false
        end
      end

      def execute_change(aug,change)
        case change[0]
        when 'set'
          raise ArgumentError,"set takes two args" unless change.length()==3
          aug.set(change[1],change[2])
        when 'setm'
          raise ArgumentError,"setm takes three args" unless change.length()==4
          aug.setm(change[1],change[2],change[3])
        when 'rm','remove'
          raise ArgumentError,"rm takes one argument" unless change.length()==2
          aug.rm(change[1])
        when 'clear'
          raise ArgumentError,"clear takes one argument" unless change.length()==2
          aug.clear(change[1])
        when 'clearm'
          raise ArgumentError,"clearm takes two arguments" unless change.length()==3
          aug.clearm(change[1],change[2])
        when 'ins','insert'
          raise ArgumentError,"insert takes three arguments" unless change.length()==4
          case change[2]
          when 'before'
            before = true
          when 'after'
            before = false
          else
            raise ArgumentError,'location for insert must be before or after'
          end
          aug.insert(change[3],change[1],before)
        when 'mv','move'
          raise ArgumentError,"mv takes two arguments" unless change.length()==3
          aug.mv(change[1],change[2])
        when 'defvar'
          raise ArgumentError,"defvar takes two arguments" unless change.length()==3
          aug.defvar(change[1],change[2])
        when 'defnode'
          raise ArgumentError,"defvar takes three arguments" unless change.length()==4
          aug.defnode(change[1],change[2],change[3])
        else
          raise ArgumentError,"Unkown augeas command #{change[0]}"
        end
      end

      def parse_changes(changes)
        changes.map{|x| parse_args(x)}
      end

      def parse_args(args)
        ret = []
        rest = args
        token = nil
        while rest != "" 
          token,rest = parse_token(rest)
          ret << token
        end
        return ret
      end

      #This is kind of ugly
      def parse_token(input)
        state = 'run'
        stack = []
        ret = ''
        sc = StringScanner.new(input)
        while state == 'run'
          chr = sc.getch
          case chr
          when nil
            if stack.empty?
              state = 'halt'
            else
              state = 'error'
            end
          when /\s/
            if stack.empty?
              state = 'halt'
            else
              ret << chr
            end
          when '['
            stack.push(chr)
            ret << chr
          when ']'
            if stack.last == '['
              stack.pop
              ret << chr
            else
              state = 'error'
            end
          when '('
            stack.push(chr)
            ret << chr
          when ')'
            if stack.last == '('
              stack.pop
              ret << chr
            else
              state = 'error'
            end
          when '"'
            if stack.last == '"'
              stack.pop
            else
              stack.push(chr)
            end
            ret << chr
          when "'"
            if stack.last == "'"
              stack.pop
            else
              stack.push(chr)
            end
            ret << chr
          else
           ret << chr
          end 
        end
        if state == 'halt'
          sc.scan(/\s*/)
          return [ret,sc.rest]
        else
          raise ArgumentError,"Couldn't parse path expresion from #{path}"
        end
      end

    end
  end
end

