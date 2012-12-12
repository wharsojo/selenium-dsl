# :nodoc:
class SeleniumDsl

  # :nodoc:
  class Version

    # :nodoc:
    class <<self
      def to_s
        [major, minor, patch, pre].compact.join('.')
      end

    private
      # :nodoc:
      def major
      0
      end

      # :nodoc:
      def minor
      1
      end

      # :nodoc:
      def patch
      2
      end

      # :nodoc:
      def pre
      nil
      end
    end
  end
end
