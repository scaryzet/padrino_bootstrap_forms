module BootstrapForms
  class FormBuilder < ::Padrino::Helpers::FormBuilder::AbstractFormBuilder
    include BootstrapForms::Helpers::Wrappers

    delegate :content_tag, :check_box_tag, :radio_button_tag, :link_to, :capture_html, :to => :template

    def initialize(*args)
      @field_options = {}
      super(*args)
    end

    %w(select email_field file_field number_field password_field phone_field search_field telephone_field text_area text_field url_field).each do |method_name|
      define_method(method_name) do |name, *args|
        @name = name
        @field_options = args.extract_options!
        
        control_group_div do
          label_field + input_div do
            extras { super(name, objectify_options(@field_options)) }
          end
        end
      end
    end

    def check_box(name, *args)
      @name = name
      @field_options = args.extract_options!

      control_group_div do
        input_div do
          if @field_options[:label] == false || @field_options[:label] == ''
            extras { super(name, objectify_options(@field_options)) }
          else
            html = extras { super(name, objectify_options(@field_options)) + (@field_options[:label].blank? ? @name.to_s.humanize : @field_options[:label]) }
            label(@name, :caption => html, :class => 'checkbox')
          end
        end
      end
    end

    def radio_buttons(name, values = {}, opts = {})
      @name = name
      @field_options = opts

      control_group_div do
        label_field + input_div do
          values.map do |text, value|
            # Padrino does not stringify false values
            options = objectify_options(@field_options).merge(:value => "#{value}")
            if @field_options[:label] == '' || @field_options[:label] == false
              extras { radio_button(name, options) + text }
            else
              html = extras { radio_button(name, options) + text }
              label("#{name}_#{value}", :caption => html, :class => 'radio')
            end
          end.join.html_safe
        end
      end
    end

    def collection_check_boxes(attribute, records, record_id, record_name, *args)
      @name = attribute
      @field_options = args.extract_options!

      control_group_div do
        label_field + extras do
          content_tag(:div, :class => 'controls') do
            records.collect do |record|
              value = record.send(record_id)
              element_id = "#{object_model_name}_#{attribute}_#{value}"

              options = objectify_options(@field_options).merge(:id => element_id, :value => value)
              options[:checked] = "checked" if [object.send(attribute)].flatten.include?(value)

              checkbox = check_box_tag("#{object_model_name}[#{attribute}][]", options)
              content_tag(:label, :class => ['checkbox', ('inline' if @field_options[:inline])].compact.join(' ')) do
                checkbox + content_tag(:span, record.send(record_name))
              end
            end.join.html_safe
          end
        end
      end
    end

    def collection_radio_buttons(attribute, records, record_id, record_name, *args)
      @name = attribute
      @field_options = args.extract_options!
      @args = args

      control_group_div do
        label_field + extras do
          content_tag(:div, :class => 'controls') do
            records.collect do |record|
              value = record.send(record_id)
              element_id = "#{object_model_name}_#{attribute}_#{value}"

              options = objectify_options(@field_options).merge(:id => element_id, :value => value)
              options[:checked] = "checked" if value == object.send(attribute)

              radiobutton = radio_button_tag("#{object_model_name}[#{attribute}]", options)
              content_tag(:label, :class => ['radio', ('inline' if @field_options[:inline])].compact.join(' ')) do
                radiobutton + content_tag(:span, record.send(record_name))
              end
            end.join.html_safe
          end
        end
      end
    end

    def uneditable_input(name, *args)
      @name = name
      @field_options = args.extract_options!
      @field_options[:id] ||= field_id(@name)
      @field_options[:label] ||= "#{field_human_name(@name)}: " # conform to Padrino's default
      @field_options[:value] ||= object.send(@name.to_sym)
      
      template.uneditable_input_tag(@name, @field_options)
    end

    def button(*args)
      template.bootstrap_button_tag(*args)
    end

    def submit(*args)
      template.bootstrap_submit_tag(*args)
    end

    def cancel(*args)
      template.bootstrap_cancel_tag(*args)
    end

    def actions(&block)
      content_tag(:div, :class => 'form-actions') do
        block_given? ? capture_html(&block) : [submit, cancel].join(' ').html_safe
      end
    end
  end
end
