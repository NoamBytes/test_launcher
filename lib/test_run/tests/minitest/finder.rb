require "test_run/searchers/git_searcher"

module TestRun
  module Tests
    module Minitest
      class Finder < Struct.new(:query, :shell, :searcher, :options)

        def self.find(query, shell, options)
          searcher = Searchers::GitSearcher.new(shell)
          new(query, shell, searcher, options).find
        end

        def find
          return tests_found_by_absolute_path if query.match(/^\//)

          return tests_found_by_name unless tests_found_by_name.empty?

          return tests_found_by_file_name unless tests_found_by_file_name.empty?

          return tests_found_by_full_regex unless tests_found_by_full_regex.empty?

          []
        end

        private

        def tests_found_by_absolute_path
          [ {file: query} ]
        end

        def tests_found_by_name
          @tests_found_by_name ||= full_regex_search("^\s*def .*#{query}.*")
        end

        def tests_found_by_file_name
          @tests_found_by_file_name ||= searcher.find_files(query).select { |f| f.match(/_test\.rb/) }.map {|f| {file: f} }
        end

        def tests_found_by_full_regex
          # we ignore the matched line since we don't know what to do with it
          @tests_found_by_full_regex ||= full_regex_search(query).map {|t| {file: t[:file]} }
        end

        def full_regex_search(regex)
          searcher.grep(regex, file_pattern: '*_test.rb')
        end
      end
    end
  end
end