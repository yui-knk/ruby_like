require_relative "./ast"

module Evaluator
  def self.create(node_root)
    Evaluator.new(node_root)
  end

  class Stack
    attr_accessor :last_value

    def initialize
      @last_value = nil
      @local_vars = {}
    end

    def set_local_var(key, value)
      @local_vars[key] = value
    end
  end

  class Evaluator
    def initialize(node_root)
      @node_root = node_root
      @function_table = {}
      @verbose = false
      @stacks = []
    end

    def evaluate
      stack = Stack.new # main
      s = stack_push_pop(stack) do
        evaluate0(@node_root)
      end

      s.last_value
    end

    private

    def current_stack
      @stacks.last
    end

    def set_last_value(val)
      current_stack.last_value = val
    end

    def stack_push_pop(stack)
      @stacks.push(stack)
      p "Stack pushed." if @verbose
      p "Stack count: #{@stacks.count}." if @verbose

      yield

      s = @stacks.pop
      p "Stack poped." if @verbose
      s
    end

    def evaluate0(node)
      p "evaluate0: #{node}." if @verbose

      case node
      when AST::Program
        node.expressions.map do |e|
          evaluate0(e)
        end.last
      when AST::Expressions
        node.expressions.map do |e|
          evaluate0(e)
        end.last
      when AST::Boolean
        v = node.value
        set_last_value(v)
        v
      when AST::Integer
        v = node.value
        set_last_value(v)
        v
      when AST::String
        v = node.value
        set_last_value(v)
        v
      when AST::DefineFunc
        f_name = node.name.name
        @function_table[f_name] = node
        set_last_value(f_name)
        f_name
      when AST::CallFunc
        f_name = node.name.name

        if f = @function_table[f_name]
          if f.arg_names.size != node.args.size
            raise "wrong number of arguments (given #{node.args.size}, expected #{f.arg_names.size})."
          end

          stack = Stack.new
          v = nil
          node.args.each.with_index do |a, i|
            stack.set_local_var(f.arg_names[i].name, a.value)
          end

          s = stack_push_pop(stack) do
            v = evaluate0(f.body)
          end

          v
        else
          raise "Unknown function: #{f_name}."
        end
      when AST::If
        v = evaluate0(node.cond)

        if v == 1 # true
          r = evaluate0(node.then_body)
        elsif v == 0 # true
          r = evaluate0(node.else_body)
        else
          raise "Unknown Boolean: #{v}"
        end

        set_last_value(r)
        r
      else
        raise "Unknown node: #{node}"
      end
    end
  end
end
