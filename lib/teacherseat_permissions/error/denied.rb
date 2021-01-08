module TeacherseatPermissions
  module Error
    class Denied < StandardError
      attr_reader :permission, :condition
      def initialize(msg="Action Not Permitted", permission, condition)
        @permission = permission
        @condition = condition
        super(msg)
      end
    end
  end
end
