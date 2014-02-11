module ActiveAdmin::Globalize
  module ActiveRecordExtension
    module Methods
      def translation_names
        self.translations.map(&:locale).map do |locale|
          I18n.t("active_admin.globalize.language.#{locale}")
        end.uniq.sort
      end

      def translations_attributes= (attrs)
        normal_attrs = {}

        attrs.each do |index, attr|
          normal_attrs[attr['locale']] ||= {}
          normal_attrs[attr['locale']].merge! attr
        end

        super(normal_attrs)
      end
    end

    def active_admin_translates(*args, &block)
      translates(*args.dup)
      args.extract_options!

      if block
        translation_class.instance_eval &block
      end

      accepts_nested_attributes_for :translations, allow_destroy: true

      include Methods
    end
  end
end

