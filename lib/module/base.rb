=begin
  $Id$

                  Arachni
  Copyright (c) 2010 Anastasios Laskos <tasos.laskos@gmail.com>

  This is free software; you can copy and distribute and modify
  this program under the term of the GPL v2.0 License
  (See LICENSE file for details)

=end

module Arachni
module Module


#
# Arachni's base module class<br/>
# To be extended by Arachni::Modules.
#    
# Defines basic structure and provides utilities to modules.
#
# @author: Zapotek <zapotek@segfault.gr> <br/>
# @version: 0.1-pre
#
class Base

    #
    # Arachni::HTTP instance for the modules
    #
    # @return [Arachni::HTTP]
    #
    attr_reader :http

    #
    # Hash page data (url, html, headers)
    #
    # @return [Hash<String, String>]
    #
    attr_reader :page_data

    #
    # Structure of the website
    #
    # @return [Hash<String, Hash<Array, Hash>>]
    #
    attr_reader :structure

    #
    # Initializes the module attributes and HTTP client
    #
    # @param  [Hash<String, String>]  page_data
    #
    # @param [Hash<String, Hash<Array, Hash>>]  structure
    #
    def initialize( page_data, structure )
        @http = Arachni::Module::HTTP.new( page_data['url']['href'] )
            
        if( page_data['cookies'] )
            @http.set_cookies( page_data['cookies'] )
        end
        
        @page_data = page_data
        @structure = structure
    end

    #
    # ABSTRACT - OPTIONAL
    #
    # It provides you with a way to setup your module's data and methods.
    #
    def prepare( )
    end

    #
    # ABSTRACT - REQUIRED
    #
    # This is used to deliver the module's payload whatever it may be.
    #
    def run( )
    end

    #
    # ABSTRACT - OPTIONAL
    #
    # This is called after run() has finished executing,
    # it restores the original HTTP session.
    def clean_up( )
    end

    #####
    #
    # *DO NOT* override the following methods.
    #
    #####

    #
    # TODO: Put all helper auditor methods in the auditor class
    # and delegate
    #
    
    #
    # Audits links injecting the injection_str as value for the
    # variables and then matching the response body against the id_regex.
    #
    # If the id argument has been provided the matched data of the
    # id_regex will be =='ed against it.
    #
    # @param    [String]     injection_str
    # @param    [String]     id_regex     regular expression string
    # @param    [String]     id  string to double check the id_regex
    #                            matched data
    #
    # @param    [Block]     block to be executed right after the
    #                            request has been made.
    #                            It will be passed the currently audited
    #                            variable and the response.
    #
    # @param    [Array<Hash<String, String>>]    the positive results of
    #                                                the audit, if no block
    #                                                has been given
    #
    def audit_links( injection_str, id_regex = nil, id = nil, &block )

        results = []
        
        # iterate through all url vars and audit each one
        inject_each_var( page_data['url']['vars'], injection_str ).each {
            |vars|

            # tell the user what we're doing
            print_status( self.class.info['Name']  + 
                " is auditing:\tlink var '" +
                vars['altered'] + "' of " + page_data['url']['href'] )
            
            # audit the url vars
            res = @http.get( page_data['url']['href'], vars['hash'] )

            # something might have gone bad,
            # make it doesn't ruin the rest of the show...
            if !res || !res.body then next end
            
            # call the passed block
            if block_given?
                block.call( var, res )
                return
            end
            
            # get matches
            result = get_matches( 'links', vars['altered'], res, injection_str,
                                   id_regex, id )
                                   
            # and append them to the results array
            results << result if result
        }

        results
    end

    #
    # Audits forms injecting the injection_str as value for the
    # variables and then matching the response body against the id_regex.
    #
    # If the id argument has been provided the matched data of the
    # id_regex will be =='ed against it.
    #
    # @param    [String]     injection_str
    # @param    [String]     id_regex     regular expression string
    # @param    [String]     id  string to double check the id_regex
    #                                matched data
    #
    # @param    [Block]     block to be executed right after the
    #                            request has been made.
    #                            It will be passed the currently audited
    #                            variable and the response.
    #
    # @param    [Array<Hash<String, String>>]    the positive results of
    #                                                the audit, if no block
    #                                                has been given
    #
    def audit_forms( injection_str, id_regex = nil, id = nil, &block )
        
        results = []
        
        # iterate through each form
        get_forms.each_with_index {
            |form, i|
            
            # if we don't have any auditable elements just return
            if !form['auditable'] then return results end
            
            # iterate through each auditable element
            inject_each_var( form['auditable'][i], injection_str ).each {
                |input|

                # inform the user what we're auditing
                print_status( self.class.info['Name']  + 
                    " is auditing:\tform input '" +
                    input['altered'] + "' with action " +
                    form['attrs']['action'] )

                # post the form
                res = @http.post( form['attrs']['action'], input )

                # make sure that we have a response before continuing
                if !res || !res.body then next end
                
                # call the block, if there's one
                if block_given?
                    block.call( input['name'], res )
                    return
                end

                # get matches
                result = get_matches( 'forms', input['altered'],
                                res, injection_str, id_regex, id )
                                
                # and append them
                results << result if result
            }
        }
        results
    end

    #
    # Audits cookies injecting the injection_str as value for the
    # cookies and then matching the response body against the id_regex.
    #
    # If the id argument has been provided the matched data of the
    # id_regex will be =='ed against it.
    #
    # @param    [String]     injection_str
    # @param    [String]     id_regex     regular expression string
    # @param    [String]     id  string to double check the id_regex
    #                                matched data
    #
    # @param    [Block]     block to be executed right after the
    #                            request has been made.
    #                            It will be passed the currently audited
    #                            variable and the response.
    #
    # @param    [Array<Hash<String, String>>]    the positive results of
    #                                                the audit, if no block
    #                                                has been given
    #
    def audit_cookies( injection_str, id_regex = nil, id = nil, &block )
        
        results = []
        
        # iterate through each cookie    
        inject_each_var( get_cookies_simple, injection_str ).each {
            |cookie|

            # tell the user what we're auditing
            print_status( self.class.info['Name']  + 
                " is auditing:\tcookie '" +
                cookie['altered'] + "' of " +
                page_data['url']['href'] )

            # make a get request with our cookies
            res = @http.cookie( page_data['url']['href']  + @http.a_to_s(
                a_to_s( url_vars ) ), cookie['hash'], nil )

            # check for a response
            if !res || !res.body then next end
            
            if block_given?
                block.call( cookie['name'], res )
                return
            end
            
            # get possible matches
            result = get_matches( 'cookies', cookie['altered'],
                        res, injection_str, id_regex, id )
            # and append them
            results << result if result
        }

        results
    end

    #
    # Returns forms from @structure
    #
    # @return    [Hash]    the form attributes, values, etc
    #
    def get_forms
        @structure['forms']
    end

    #
    # Returns links from @structure
    #
    # @return    [Hash]    the link attributes, variables, etc
    #
    def get_links
        @structure['links']
    end

    #
    # Returns cookies from @structure as a name=>value hash
    #
    # @return    [Hash]    the cookie attributes, values, etc
    #
    def get_cookies_simple
        cookies = Hash.new( )
        @structure['cookies'].each {
            |cookie|
            cookies[cookie['name']] = cookie['value']
        }
        cookies
    end

    #
    # Returns extended cookie information from @structure
    #
    # @return    [Array]    the cookie attributes, values, etc
    #
    def get_cookies
        @structure['cookies']
    end
        
    private
    
    def get_matches( where, var, res, injection_str, id_regex, id )
        
        # fairly obscure condition...pardon me...
        if ( id && res.body.scan( id_regex )[0] == id ) ||
           ( !id && res.body.scan( id_regex )[0].size > 0 )
        
            print_ok( self.class.info['Name'] + " in: #{where} var #{var}" +
            '::' + page_data['url']['href'] )
            
            print_verbose( "Injected str:\t" + injection_str )    
            print_verbose( "ID str:\t\t" + id )
            print_verbose( "Matched regex:\t" + id_regex.to_s )
            print_verbose( '---------' ) if only_positives?
    
            return {
                'var'          => var,
                'url'          => page_data['url']['href'],
                'injected'     => injection_str,
                'id'           => id,
                'regexp'       => id_regex.to_s,
                'regexp_match' => res.body.scan( id_regex ),
                'response'     => res.body,
                'headers'      => {
                    'request'    => get_request_headers( ),
                    'response'   => get_response_headers( res ),    
                }
            }
        end
    end
    
    def get_request_headers( )
        @http.init_headers    
    end
    
    def get_response_headers( res )
        
        header = Hash.new
        res.each_capitalized {
            |key|
            header[key] = res.get_fields( key ).join( "\n" )
        }
        
        header
    end
    
    def get_data_file( filename, &block )
        
        # the path of the module that called us
        mod_path = block.source_location[0]
        
        # the name of the module that called us
        mod_name = File.basename( mod_path, ".rb")
        
        # the path to the module's data file directory
        path    = File.expand_path( File.dirname( mod_path ) ) +
            '/' + mod_name + '/'
                
        file = File.open( path + '/' + filename ).each {
            |line|
            yield line
        }
        
        file.close
             
    end
    
    def  inject_each_var( url_vars, to_inj )
        
        var_combo = []
        url_vars.keys.each {
            |k|
            
        if( !url_vars[k] ) then url_vars[k] = '' end 
            
            var_combo << { 
                'altered' => k,
                'hash'    => url_vars.merge( { k => to_inj } ) }
        }
        
        var_combo
    end


end
end
end