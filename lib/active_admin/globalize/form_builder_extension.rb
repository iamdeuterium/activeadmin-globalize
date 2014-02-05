module ActiveAdmin
  module Globalize
    module FormBuilderExtension
      extend ActiveSupport::Concern

      attr_reader :locales_switch

      def translated_inputs(name = "Translations", options = {}, &block)
        options.symbolize_keys!
        switch_locale = options.fetch(:switch_locale, false)
        auto_sort = options.fetch(:auto_sort, true)
        form_buffers.last << template.content_tag(:div, class: "activeadmin-translations") do
          template.content_tag(:ul, class: "available-locales") do
            (auto_sort ? I18n.available_locales.sort : I18n.available_locales).map do |locale|
              template.content_tag(:li) do
                I18n.with_locale(switch_locale ? locale : I18n.locale) do
                  template.content_tag(:a, I18n.t(:"active_admin.globalize.language.#{locale}"), href:".locale-#{locale}")
                end
              end
            end.join.html_safe
          end <<
          (auto_sort ? I18n.available_locales.sort : I18n.available_locales).map do |locale|
            translation = object.translations.find { |t| t.locale.to_s == locale.to_s }
            translation ||= object.translations.build(locale: locale)
            fields = proc do |form|
              form.input(:locale, as: :hidden)
              form.input(:id, as: :hidden)
              I18n.with_locale(switch_locale ? locale : I18n.locale) do
                block.call(form)
              end
            end
            inputs_for_nested_attributes(
              for: [:translations, translation ],
              class: "inputs locale locale-#{translation.locale}",
              &fields
            )
          end.join.html_safe
        end
      end

      def inputs_with_translations(*args, &block)
        @locales_switch = true

        options = args.extract_options!
        options[:title] = "#{field_set_title_from_args(*args)}&nbsp;#{translated_input_switch.html_safe}"
        args << options

        inputs(*args, &block)
      end

      def input(method, *args)
        if object.class.respond_to?(:translated?) and object.translated?(method)
          translated_input(method, *args)
        else
          super
        end
      end

      def translated_input(method, *args)
        options = args.extract_options!
        options.reverse_merge! label: translated_input_label(method)
        args << options

        form_buffers.last << template.content_tag(:div, class: "activeadmin-translation-input") do
          (translated_input_switch unless locales_switch).to_s.html_safe <<
          translated_input_inputs(method, *args)
        end
      end

      private

      def translated_input_inputs(method, *args)
        I18n.available_locales.map do |locale|
          translation = object.translations.find { |t| t.locale.to_s == locale.to_s }
          translation ||= object.translations.build(locale: locale)
          fields = proc do |form|
            form.input(:locale, as: :hidden)
            form.input(:id, as: :hidden)
            form.input(method, *args)
          end
          inputs_for_nested_attributes(
              for: [:translations, translation],
              class: "locale locale-#{translation.locale} #{'locale-current' if locale == I18n.locale}",
              &fields
          )
        end.join.html_safe
      end

      def translated_input_switch
        template.content_tag(:ul, class: "available-locales-switch") do
          I18n.available_locales.map do |locale|
            template.content_tag(:li) do
              template.content_tag(:a, I18n.t(:"active_admin.globalize.language.#{locale}"), href:".locale-#{locale}", class: ('locale-current' if locale == I18n.locale))
            end
          end.join.html_safe
        end
      end

      def translated_input_label(method)
        object.class.human_attribute_name(method.to_s)
      end

      module ClassMethods
      end
    end
  end
end

