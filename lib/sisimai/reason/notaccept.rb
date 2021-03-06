module Sisimai
  module Reason
    # Sisimai::Reason::NotAccept checks the bounce reason is "notaccept" or not.
    # This class is called only Sisimai::Reason class.
    #
    # This is the error that a destination mail server does ( or can ) not accept
    # any email. In many case, the server is high load or under the maintenance.
    # Sisimai will set "notaccept" to the reason of email bounce if the value of
    # Status: field in a bounce email is "5.3.2" or the value of SMTP reply code
    # is 556.
    module NotAccept
      # Imported from p5-Sisimail/lib/Sisimai/Reason/NotAccept.pm
      class << self
        def text; return 'notaccept'; end
        def description
          return 'Delivery failed due to a destination mail server does not accept any email'
        end

        # Try to match that the given text and regular expressions
        # @param    [String] argv1  String to be matched with regular expressions
        # @return   [True,False]    false: Did not match
        #                           true: Matched
        def match(argv1)
          return nil unless argv1

          # Destination mail server does not accept any message
          regex = %r{(?:
               Name[ ]server:[ ][.]:[ ]host[ ]not[ ]found # Sendmail
              |55[46][ ]smtp[ ]protocol[ ]returned[ ]a[ ]permanent[ ]error
            )
          }ix

          return true if argv1 =~ regex
          return false
        end

        # Remote host does not accept any message
        # @param    [Sisimai::Data] argvs   Object to be detected the reason
        # @return   [True,False]            true: Not accept
        #                                   false: Accept
        # @see http://www.ietf.org/rfc/rfc2822.txt
        def true(argvs)
          return nil unless argvs
          return nil unless argvs.is_a? Sisimai::Data
          return true if argvs.reason == Sisimai::Reason::NotAccept.text

          diagnostic = argvs.diagnosticcode || ''
          v = false

          if argvs.replycode =~ /\A(?:521|554|556)\z/
            # SMTP Reply Code is 554 or 556
            v = false
          else
            # Check the value of Diagnosic-Code: header with patterns
            if argvs.smtpcommand == 'MAIL'
              # Matched with a pattern in this class
              v = true if Sisimai::Reason::NotAccept.match(diagnostic)
            end
          end

          return v
        end

      end
    end
  end
end



