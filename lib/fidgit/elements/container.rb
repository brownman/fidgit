# encoding: utf-8

require_relative 'element'

module Fidgit
  # A container that contains Elements.
  # @abstract
  class Container < Element
    def size; @children.size; end
    def each(&block); @children.each &block; end
    def find(&block); @children.find &block; end
    def index(value); @children.index value; end
    def [](index); @children[index]; end

    def x=(value)
      each {|c| c.x += value - x }
      super(value)
    end

    def y=(value)
      each {|c| c.y += value - y }
      super(value)
    end

    # @param (see Element#initialize)
    #
    # @option (see Element#initialize)
    def initialize(options = {})
      options[:border_color] = default(:debug, :border_color) if Fidgit.debug_mode?

      @children = []

      super(options)
    end

    def add(element)
      element.send :parent=, self
      @children.push element

      recalc
      nil
    end

    def remove(element)
      @children.delete element
      element.send :parent=, nil

      recalc
      nil
    end

    def insert(position, element)
      @children.insert position, element
      element.send :parent=, self

      recalc
      nil
    end

    # Create a button within the container.
    def button(text, options = {}, &block)
      Button.new(text, {parent: self}.merge!(options), &block)
    end

    # Create a color picker within the container.
    def color_picker(options = {}, &block)
      ColorPicker.new({parent: self}.merge!(options), &block)
    end

    # Create a color well within the container.
    def color_well(options = {}, &block)
      ColorWell.new({parent: self}.merge!(options), &block)
    end

    def combo_box(options = {}, &block)
      ComboBox.new({parent: self}.merge!(options), &block)
    end

    def file_browser(type, options = {}, &block)
      FileBrowser.new(type, {parent: self}.merge!(options), &block)
    end

    def group(options = {}, &block)
      Group.new({parent: self}.merge!(options), &block)
    end

    # Create a label within the container.
    def label(text, options = {})
      Label.new(text, {parent: self}.merge!(options))
    end

    def list(options = {}, &block)
      List.new({parent: self}.merge!(options), &block)
    end

    def pack(arrangement, options = {}, &block)
      klass = case arrangement
        when :horizontal
          HorizontalPacker
        when :vertical
          VerticalPacker
        when :grid
          GridPacker
        else
          raise ArgumentError, "packing arrangement must be one of :horizontal, :vertical or :grid"
      end

      klass.new({parent: self}.merge!(options), &block)
    end

    def radio_button(text, value, options = {}, &block)
      RadioButton.new(text, value, {parent: self}.merge!(options), &block)
    end

    def scroll_area(options = {}, &block)
      ScrollArea.new({parent: self}.merge!(options), &block)
    end

    def scroll_window(options = {}, &block)
      ScrollWindow.new({parent: self}.merge!(options), &block)
    end

    def slider(options = {}, &block)
      Slider.new({parent: self}.merge!(options), &block)
    end

    def text_area(options = {}, &block)
      TextArea.new({parent: self}.merge!(options), &block)
    end

    def toggle_button(text, options = {}, &block)
      ToggleButton.new(text, {parent: self}.merge!(options), &block)
    end

    def clear
      @children.each {|child| child.send :parent=, nil }
      @children.clear

      recalc

      nil
    end

    def update
      each { |c| c.update }

      nil
    end

    # Returns the element within this container that was hit,
    # @return [Element, nil] The element hit, otherwise nil.
    def hit_element(x, y)
      @children.reverse_each do |child|
        case child
        when Container, Composite
          if element = child.hit_element(x, y)
            return element
          end
        else
          return child if child.hit?(x, y)
        end
      end

      self if hit?(x, y)
    end

    protected
    def draw_foreground
      each { |c| c.draw }

      font.draw self.class.name, x, y, z if Fidgit.debug_mode?

      nil
    end

    protected
    # Any container passed a block will allow you access to its methods.
    def post_init_block(&block)
      case block.arity
        when 1
          yield self
        when 0
          instance_methods_eval &block
        else
          raise "block arity must be 0 or 1"
      end
    end
  end
end