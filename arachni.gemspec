# coding: utf-8
=begin
    Copyright 2010-2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

Gem::Specification.new do |s|
    require File.expand_path( File.dirname( __FILE__ ) ) + '/lib/arachni/version'

    s.required_ruby_version = '>= 1.9.2'

    s.name              = 'arachni'
    s.version           = Arachni::VERSION
    s.date              = Time.now.strftime( '%Y-%m-%d' )
    s.summary           = 'Arachni is a feature-full, modular, high-performance' +
        ' Ruby framework aimed towards helping penetration testers and' +
        ' administrators evaluate the security of web applications.'

    s.homepage          = 'https://www.arachni-scanner.com'
    s.email             = 'tasos.laskos@gmail.com'
    s.authors           = [ 'Tasos Laskos' ]

    s.files            += Dir.glob( 'data/**/**' )
    s.files            += Dir.glob( 'external/**/**' )
    s.files            += Dir.glob( 'extras/**/**' )
    s.files            += Dir.glob( 'gfx/**/**' )
    s.files            += Dir.glob( 'lib/**/**' )
    s.files            += Dir.glob( 'logs/**/**' )
    s.files            += Dir.glob( 'modules/**/**' )
    s.files            += Dir.glob( 'fingerprinters/**/**' )
    s.files            += Dir.glob( 'path_extractors/**/**' )
    s.files            += Dir.glob( 'plugins/**/**' )
    s.files            += Dir.glob( 'profiles/**/**' )
    s.files            += Dir.glob( 'reports/**/**' )
    s.files            += Dir.glob( 'rpcd_handlers/**/**' )
    s.files            += Dir.glob( 'spec/**/**' )
    s.files            += %w(Gemfile Rakefile arachni.gemspec)
    s.test_files        = Dir.glob( 'spec/**/**' )

    s.executables       = [ 'arachni', 'arachni_rpcd_monitor', 'arachni_rpcd',
                            'arachni_rpc', 'arachni_console', 'arachni_script',
                            'arachni_multi' ]

    s.extra_rdoc_files  = %w(README.md ACKNOWLEDGMENTS.md LICENSE.md
                            AUTHORS.md CHANGELOG.md CONTRIBUTORS.md
                            EXPLOITATION.md HACKING.md NOTICE)

    s.rdoc_options      = [ '--charset=UTF-8' ]

    s.add_dependency 'bundler'

    # RPC client/server implementation.
    s.add_dependency 'arachni-rpc-em',  '0.2'

    # HTTP interface.
    s.add_dependency 'typhoeus',        '~> 0.3.3'

    # Fallback URI parsing and encoding utilities.
    s.add_dependency 'addressable',     '~> 2.3.2'

    # E-mail plugin.
    s.add_dependency 'pony'

    # Printing complex objects.
    s.add_dependency 'awesome_print'

    # JSON report.
    s.add_dependency 'json'

    # For the Arachni console (arachni_console).
    s.add_dependency 'rb-readline'

    # Markup parsing.
    s.add_dependency 'nokogiri',        '>= 1.5.7.rc1'

    # System resource consumption and other proc info for the Grid.
    s.add_dependency 'sys-proctable',   '>= 0.9.1'

    # Outputting data in table format (arachni_rpcd_monitor).
    s.add_dependency 'terminal-table',  '>= 1.4.2'

    # For CLI interfaces.
    s.add_dependency 'highline'

    s.add_development_dependency 'rake'
    s.add_development_dependency 'rspec'

    # For test mini-servers.
    s.add_development_dependency 'thin'
    s.add_development_dependency 'sinatra',         '~> 1.3.2'
    s.add_development_dependency 'sinatra-contrib', '~> 1.3.1'

    s.post_install_message = <<MSG

Thank you for installing Arachni, here are some resources which should
help you make the best of it:

Homepage           - http://arachni-scanner.com
Blog               - http://arachni-scanner.com/blog
Documentation      - http://arachni-scanner.com/wiki
Support            - http://support.arachni-scanner.com
GitHub page        - http://github.com/Arachni/arachni
Code Documentation - http://rubydoc.info/github/Arachni/arachni
Author             - Tasos "Zapotek" Laskos (http://twitter.com/Zap0tek)
Twitter            - http://twitter.com/ArachniScanner
Copyright          - 2010-2013 Tasos Laskos
License            - Apache License v2

Please do not hesitate to ask for assistance (via the support portal)
or report a bug (via GitHub Issues) if you come across any problem.

MSG

    s.description = <<DESCRIPTION
Arachni is an Open Source, feature-full, modular, high-performance Ruby framework
aimed towards helping penetration testers and administrators evaluate the security
of web applications.

It is smart, it trains itself by learning from the HTTP responses it receives
during the audit process and is able to perform meta-analysis using a number of
factors in order to correctly assess the trustworthiness of results and intelligently
identify false-positives.

Unlike other scanners, it takes into account the dynamic nature of web applications,
can detect changes caused while travelling through the paths of a web application’s
cyclomatic complexity and is able to adjust itself accordingly. This way attack/input
vectors that would otherwise be undetectable by non-humans are seamlessly handled by Arachni.

Moreover, Arachni yields great performance due to its asynchronous HTTP model
(courtesy of Typhoeus) — especially when combined with a High Performance Grid
setup which allows you to combine the resources of multiple nodes for lightning
fast scans. Thus, you’ll only be limited by the responsiveness of the server under audit.

Finally, it is versatile enough to cover a great deal of use cases, ranging from
a simple command line scanner utility, to a global high performance grid of
scanners, to a Ruby library allowing for scripted audits, to a multi-user
multi-scan web collaboration platform.

**Note**: Despite the fact that Arachni is mostly targeted towards web application
security, it can easily be used for  general purpose scraping, data-mining, etc
with the addition of custom modules.
DESCRIPTION

end
