require 'rspec'
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/address")
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/query_add")
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/query_remove")
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/query_set")
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/query_unset")
require File.expand_path("#{File.dirname __FILE__}/../../../../../lib/htty/cli/commands/query_unset_all")

describe HTTY::CLI::Commands::QueryUnset do
  let :klass do
    subject.class
  end

  let :session do
    HTTY::Session.new nil
  end

  describe 'class' do
    it 'should be an alias_for the expected command' do
      klass.alias_for.should == nil
    end

    it 'should have the expected aliases' do
      klass.aliases.should == []
    end

    it 'should belong to the expected category' do
      klass.category.should == 'Navigation'
    end

    it 'should have the expected command_line' do
      klass.command_line.should == 'query-unset'
    end

    it 'should have the expected command_line_arguments' do
      klass.command_line_arguments.should == 'NAME [VALUE]'
    end

    it 'should have the expected help' do
      klass.help.should == 'Removes query-string parameters from the ' +
                           "request's address"
    end

    it 'should have the expected help_extended' do
      expected = <<-end_help_extended
Removes one or more a query-string parameters used for the request. Does not communicate with the host.

The difference between this command and \e[1mquery-r[emove]\e[0m is that this command removes all matching parameters instead of removing matches one at a time from the end of the address.

The name of the query-string parameter will be URL-encoded if necessary.

The console prompt shows the address for the current request.
      end_help_extended
      klass.help_extended.should == expected.chomp
    end

    it 'should have the expected see_also_commands' do
      klass.see_also_commands.should == [HTTY::CLI::Commands::QuerySet,
                                         HTTY::CLI::Commands::QueryUnsetAll,
                                         HTTY::CLI::Commands::QueryAdd,
                                         HTTY::CLI::Commands::QueryRemove,
                                         HTTY::CLI::Commands::Address]
    end

    describe 'build_for' do
      it 'should correctly handle a valid, unabbreviated command line' do
        built = klass.build_for('query-unset foo bar', :session => :the_session)
        built.should be_instance_of(klass)
        built.arguments.should == %w(foo bar)
        built.session.should   == :the_session
      end

      it 'should correctly handle a command line with a bad command' do
        built = klass.build_for('x baz qux', :session => :another_session)
        built.should == nil
      end
    end
  end

  describe 'instance' do
    def instance(*arguments)
      klass.new :session => session, :arguments => arguments
    end

    describe 'with existing query string with duplicate keys set' do
      before :each do
        session.requests.last.uri.query = 'test=true&test=false'
      end

      describe 'with only key specified' do
        it 'should remove all entries' do
          instance('test').perform
          session.requests.last.uri.query.should == ''
        end
      end

      describe 'with key and value specified' do
        it 'should remove matching entry only' do
          instance('test', 'true').perform
          session.requests.last.uri.query.should == 'test=false'
        end
      end
    end
  end
end