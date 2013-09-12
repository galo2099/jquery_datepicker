require 'date'

module JqueryDatepicker
  def self.available_datepicker_options
    [:disabled, :altField, :altFormat, :appendText, :autoSize, :buttonImage, :buttonImageOnly, :buttonText, :calculateWeek, :changeMonth, :changeYear, :closeText, :constrainInput, :currentText, :dateFormat, :dayNames, :dayNamesMin, :dayNamesShort, :defaultDate, :duration, :firstDay, :gotoCurrent, :hideIfNoPrevNext, :isRTL, :maxDate, :minDate, :monthNames, :monthNamesShort, :navigationAsDateFormat, :nextText, :numberOfMonths, :prevText, :selectOtherMonths, :shortYearCutoff, :showAnim, :showButtonPanel, :showCurrentAtPos, :showMonthAfterYear, :showOn, :showOptions, :showOtherMonths, :showWeek, :stepMonths, :weekHeader, :yearRange, :yearSuffix]
  end

  def self.split_options(options)
    tf_options = options.slice!(*available_datepicker_options)
    return options, tf_options
  end

  module FormHelper

    include ActionView::Helpers::JavaScriptHelper

    # Mehtod that generates datepicker input field inside a form
    def datepicker(object_name, method, options = {})
      dp_options, tf_options = JqueryDatepicker::split_options(options)

      instance_tag = JqueryDatepicker::InstanceTag.new(object_name, method, self, options)
      alt_field_tag_id = instance_tag.get_name_and_id()["id"]
      text_field_tag_id = alt_field_tag_id + "_datepicker_ui"

      text_tag = ActionView::Helpers::Tags::TextField.new(object_name, method, self, tf_options.merge(:id => text_field_tag_id, :name => ""))
      hidden_tag = ActionView::Helpers::Tags::HiddenField.new(object_name, method, self, tf_options)
      html = text_tag.render
      html += hidden_tag.render

      dp_options.merge!(:altField => "##{alt_field_tag_id}", :altFormat => 'yy-mm-dd')
      html += datepicker_common_javascript(text_field_tag_id, alt_field_tag_id, instance_tag.get_value(instance_tag.get_object), dp_options)
      html.html_safe
    end

    # Mehtod that generates datepicker input field inside a form
    def datepicker_tag(name, value, options = {})
      dp_options, tf_options = JqueryDatepicker::split_options(options)
      dp_options.merge!(:altField => "##{name}", :altFormat => 'yy-mm-dd')
      text_field_tag_id = name + "_datepicker_ui"
      html = text_field_tag("", nil, tf_options.merge(:id => text_field_tag_id, :name => ""))
      html += hidden_field_tag(name, value, tf_options)
      html += datepicker_common_javascript(text_field_tag_id, name, value, dp_options)
      html.html_safe
    end

   private
    def datepicker_common_javascript(tag_id, alt_tag_id, value, options)
      javascript_tag <<-EOL
        jQuery(document).ready(function() {
          var text_field_tag = jQuery('##{h tag_id}');
          text_field_tag.datepicker(#{options.to_json});
          var current_datepicker_format = text_field_tag.datepicker("option", "dateFormat");
          text_field_tag.datepicker("option", "dateFormat", "yy-mm-dd");
          text_field_tag.datepicker("setDate", '#{value}');
          text_field_tag.datepicker("option", "dateFormat", current_datepicker_format);
          text_field_tag.change(function(){
            if (!jQuery(this).val()) jQuery("##{h alt_tag_id}").val('');
          });
        });
      EOL
    end
  end
end

class JqueryDatepicker::InstanceTag < ActionView::Helpers::Tags::Base
  def get_name_and_id(options = {})
    add_default_name_and_id(options)
    options
  end

  def get_value(object)
    value(object)
  end

  def get_object
    object
  end
end

module JqueryDatepicker::FormBuilder
  def datepicker(method, options = {})
    @template.datepicker(@object_name, method, objectify_options(options))
  end
end
