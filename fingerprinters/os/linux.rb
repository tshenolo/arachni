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

module Arachni
module Platform::Fingerprinters

#
# Identifies Linux operating systems.
#
# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
#
# @version 0.1
#
class Linux < Platform::Fingerprinter

    IDs = %w(linux ubuntu gentoo debian dotdeb centos redhat sarge etch lenny
                squeeze wheezy jessie) | ['red hat', 'scientific linux']

    def run
        IDs.each do |id|
            next if !server_or_powered_by_include? id
            return platforms << :linux
        end
    end

end

end
end
