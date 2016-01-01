#!/usr/bin/env ruby

require 'parslet'

class XBKconfig
    class Parser
        class Parser < Parslet::Parser
            rule(:newline) { str("\n") >> str("\r").maybe }
            rule(:comment) {
                str("#").repeat(1) >>
                ((newline.absent? >> any).repeat).as(:comment) >>
                newline.repeat
            }
            rule(:doubleQuote) { str('"') }
            rule(:commandLine) {
                (doubleQuote >>
                (newline.absent? >> doubleQuote.absent? >> any).repeat >>
                doubleQuote).as(:command) >> match["\s"].repeat >> newline
            }
            rule(:bind) {
                (newline.absent? >> doubleQuote.absent? >> any).repeat.as(:bind) >>
                newline.repeat
            }
            rule(:bindEntry) { ( commandLine >> bind ).as(:bindEntry) }
            rule(:main) { ( comment | bindEntry ).repeat }
            root(:main)
        end

        class Transform < Parslet::Transform
            rule(:bindEntry => { :command => simple(:c), :bind => simple(:b) } ) do
                { command: String(c), bind: String(b) }
            end
            rule(:comment => simple(:comm)) { { comment: String(comm) } }
        end
    end
end
