require 'chef/provider'
require 'augeas'
require 'chef/util/diff'
require 'strscan'

class Chef
  class Provider
    class Augeas < Chef::Provider

      def initialize(new_resource,run_context=nil)
        super(new_resource,run_context)
      end

      def load_current_resource
        true
      end

      def action_run
        aug = ::Augeas::open()
        if need_run?(aug,@new_resource.only_if)
          parse_changes(@new_resource.changes()).map{|x| execute_change(aug,x)}
        end
        aug.close()
      end

      def need_run?(aug,only_if)
        if only_if
          check_guard(parse_args(only_if))
        end
        return true
      end

      def check_guard(guard)
        case guard[0]
        when 'get'
          process_get(guard)
        end
      end

      def process_get(guard)
        path,comp,value = guard[1],guard[2],guard[3]
        unless ['>','<','<=','>=','==','!=','=~'].include?(comp)
          raise ArgumentError,"Uknown comparator #{comp}"
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

