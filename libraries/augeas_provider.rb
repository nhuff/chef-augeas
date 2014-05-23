# rubocop:disable Eval,CyclomaticComplexity
require 'chef/provider'
require 'chef/util/diff'
require 'chef/log'
require 'strscan'
require 'set'

class Chef
  class Provider
    # Chef Provider for augeas resource
    class Augeas < Chef::Provider
      def initialize(new_resource,run_context = nil)
        super(new_resource,run_context)
        require 'augeas'
      end

      def load_current_resource
        true
      end

      def action_run
        aug = open_augeas
        changes = parse_changes(@new_resource.changes)
        if need_run?(aug,@new_resource.run_if,changes)
          execute_changes(aug,changes)
        end
        aug.close
      end

      def open_augeas
        if @new_resource.incl && !@new_resource.lens
          fail ArgumentError, "can't set incl without lens"
        end
        flags = ::Augeas::SAVE_NEWFILE | ::Augeas::NO_LOAD
        flags |= ::Augeas::NO_MODL_AUTOLOAD if @new_resource.lens
        aug = ::Augeas.open(nil,nil,flags)
        if @new_resource.lens
          aug.set('/augeas/load/Xfm/lens',@new_resource.lens)
        end
        if @new_resource.incl
          aug.set('/augeas/load/Xfm/incl',@new_resource.incl)
        end
        begin
          aug.load!
        rescue ::Augeas::Error => e
          log_errors(aug)
          raise e
        end
        aug
      end

      def need_run?(aug,run_if,changes)
        if run_if
          o_i = check_guard(aug,parse_args(run_if))
        else
          o_i = true
        end
        i_s = in_sync?(aug,changes)
        return (o_i && !i_s)
      end

      def execute_changes(aug,changes)
        saved_events = aug.match('/augeas/events/saved')

        # This is to work around a bug in at least ubuntu-12.04 that causes
        # load to not reload the files after we switch the save mode
        saved_events.map { |x| aug.rm("/augeas#{aug.get(x)}/mtime") }

        saved_files  = Set.new(saved_events.map { |x| aug.get(x).sub(/^\/files/,'') })
        diffs = saved_files.map { |x| Chef::Util::Diff.new.udiff(x,x + '.augnew') }
        diffs.map { |x| Chef::Log.info(x) }
        saved_files.map { |x| ::File.delete(x + '.augnew') }

        aug.set('/augeas/save','overwrite')
        begin
          aug.load!
          changes.map { |x| execute_change(aug,x) }
          aug.save!
        rescue ::Augeas::Error => e
          log_errors(aug)
          raise e
        end
      end

      def in_sync?(aug,changes)
        changes.map { |x| execute_change(aug,x) }
        begin
          aug.save!
        rescue ::Augeas::Error => e
          log_errors(aug)
          raise e
        end
        saved_events = aug.match('/augeas/events/saved')
        return false if saved_events.size > 0
        return true
      end

      def check_guard(aug,guard)
        case guard[0]
        when 'get'
          return process_get(aug,guard)
        when 'match'
          return process_match(aug,guard)
        else
          fail ArgumentError,"#{guard[0]} is not a valid matcher in run_if"
        end
      end

      def process_match(aug,guard)
        if guard.length < 4
          fail ArgumentError,'match requires at least 3 arguments'
        end

        ret = false
        path,verb = guard[1],guard[2]
        matches = aug.match(path) || []
        case verb
        when 'size'
          if guard.length != 5
            fail ArgumentError,'match with size requires 4 args'
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
          fail ArgumentError,"verb #{verb} not supported by match"
        end
        return ret
      end

      def process_get(aug,guard)
        fail ArgumentError,'get requires 3 arguments' if guard.length != 4
        ret = false
        path,comp,value = guard[1],guard[2],guard[3]
        unless ['>','<','<=','>=','==','!=','=~'].include?(comp)
          fail ArgumentError,"Uknown comparator #{comp}"
        end
        cur = aug.get(path) || ''

        case comp
        when '>','<','<=','>='
          if numeric?(cur) && numeric?(value)
            curf = cur.to_f
            valf = value.to_f
            ret = curf.send(comp,valf)
          else
            ret = cur.send(comp,value)
          end
        when '!='
          ret = (value != cur)
        when '=~'
          ret = (cur =~ Regexp.new(value))
        else
          ret = cur.send(comp,value)
        end

        return ret
      end

      def numeric?(s)
        case s
        when Fixnum
          true
        when String
          s.match(/\A[+-]?\d+?(\.\d+)?\Z/n).nil? ? false : true
        else
          false
        end
      end

      def execute_change(aug,change)
        case change[0]
        when 'set'
          fail ArgumentError,'set takes two args' unless change.length == 3
          aug.set(change[1],change[2])
        when 'setm'
          fail ArgumentError,'setm takes three args' unless change.length == 4
          aug.setm(change[1],change[2],change[3])
        when 'rm','remove'
          fail ArgumentError,'rm takes one argument' unless change.length == 2
          aug.rm(change[1])
        when 'clear'
          fail ArgumentError,'clear takes one argument' unless change.length == 2
          aug.clear(change[1])
        when 'clearm'
          fail ArgumentError,'clearm takes two arguments' unless change.length == 3
          aug.clearm(change[1],change[2])
        when 'ins','insert'
          fail ArgumentError,'insert takes three arguments' unless change.length == 4
          case change[2]
          when 'before'
            before = true
          when 'after'
            before = false
          else
            fail ArgumentError,'location for insert must be before or after'
          end
          aug.insert(change[3],change[1],before)
        when 'mv','move'
          fail ArgumentError,'mv takes two arguments' unless change.length == 3
          aug.mv(change[1],change[2])
        when 'defvar'
          fail ArgumentError,'defvar takes two arguments' unless change.length == 3
          aug.defvar(change[1],change[2])
        when 'defnode'
          fail ArgumentError,'defvar takes three arguments' unless change.length == 4
          aug.defnode(change[1],change[2],change[3])
        else
          fail ArgumentError,"Unkown augeas command #{change[0]}"
        end
      end

      def parse_changes(changes)
        changes.map { |x| parse_args(x) }
      end

      def parse_args(args)
        ret = []
        rest = args
        while rest != ''
          token,rest = parse_token(rest)
          ret << token
        end
        return ret
      end

      # This is kind of ugly
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
          fail ArgumentError,"Couldn't parse path expresion from #{path}"
        end
      end

      def log_errors(aug)
        errors = aug.match('/augeas//error')
        errors.each do |errnode|
          error = aug.get(errnode)
          Chef::Log.error("#{errnode} = #{error}") unless error.nil?
          aug.match("#{errnode}/*").each do |subnode|
            subvalue = aug.get(subnode)
            Chef::Log.error("#{subnode} = #{subvalue}")
          end
        end
      end
    end
  end
end
