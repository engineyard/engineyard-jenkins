# Extension: Sorts the Dir[lookup] to ensure deterministic ordering of actions
# to allow test assertions

class Thor
  module Actions
    class Directory < EmptyDirectory #:nodoc:
      protected

        def execute!
          lookup = config[:recursive] ? File.join(source, '**') : source
          lookup = File.join(lookup, '{*,.[a-z]*}')

          Dir[lookup].sort.each do |file_source|
            next if File.directory?(file_source)
            file_destination = File.join(given_destination, file_source.gsub(source, '.'))
            file_destination.gsub!('/./', '/')

            case file_source
              when /\.empty_directory$/
                dirname = File.dirname(file_destination).gsub(/\/\.$/, '')
                next if dirname == given_destination
                base.empty_directory(dirname, config)
              when /\.tt$/
                destination = base.template(file_source, file_destination[0..-4], config, &@block)
              else
                destination = base.copy_file(file_source, file_destination, config, &@block)
            end
          end
        end

    end
  end
end
