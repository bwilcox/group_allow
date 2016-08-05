require 'fileutils'
Puppet::Type.type(:group_allow).provide(:aix) do
  desc "Provides support for adding group members for local login."
  confine :operatingsystem => [:aix]

  commands :lsgroup => '/usr/sbin/lsgroup',
           :lsuser => '/usr/sbin/lsuser',
           :grep => '/usr/bin/grep',
           :chsec => '/usr/bin/chsec'

  def exists?

    users = Array.new
    @missing = Array.new

    # Get the list of group members from LDAP
    begin
      groupinfo = lsgroup('-R', 'LDAP', '-a', 'users', resource[:name])
      ulist = groupinfo.chomp.split[1].split('=')[1]
      if ulist.nil?
        raise ArgumentError
      else
        users = groupinfo.chomp.split[1].split('=')[1].split(',')
      end
      #puts "Group users: #{users.inspect}"

      # Get the list of account currently allowed to login
      allowed = Array.new
      begin
        all = grep('^[a-zA-Z]', '/etc/security/user')
        all.split("\n").each do |line|
          allowed << line.split(':')[0]
        end

        #puts "Users on server: #{allowed.inspect}"

        users.each do |user|
          unless allowed.include?(user)
            #puts "#{user} not on server"
            @missing << user
          end
        end

        # If @users is empty then there is nothing to do.
        if @missing.empty?
          return true
        else
          return false
        end

      rescue Puppet::ExecutionFailure
        fail "Could not determine currently allowed logins."
      end
    rescue Puppet::ExecutionFailure
      info("Group #{resource[:name]} does not exist in LDAP")
      # We return true here because we don't want anything to 
      # run if the group does not exist in LDAP.
      return true
    rescue NoMethodError
      info("Group #{resource[:name]} has no members in LDAP")
      # We return true here because we don't want anything to 
      # run if the group does not exist in LDAP.
      return true
    rescue ArgumentError
      notice("Group #{resource[:name]} has no members.")
    end

  end

  def create
    # Exists was false so take the @users array and add anything
    # in it.
    #puts "Users to add #{@missing}"
    @missing.each do |user|
      #puts "Adding #{user}"

      begin
        # Verify the user is not already on the system
        grep('-w', "#{user}:", '/etc/security/user')

      rescue Puppet::ExecutionFailure

        # Get the home directory
        begin
          begin
            home = lsuser('-R', 'LDAP', '-a', 'home', user).split('=')[1].chomp
          rescue
            fail "Could not get home directory for #{user}"
            next
          end

          # Get the primary group
          begin
            pgrp = lsuser('-R', 'LDAP', '-a', 'pgrp', user).split('=')[1].chomp
          rescue 
            fail "Could not get primary group for #{user}"
            next
          end

          # Make the home directory unless it already exists
          unless FileTest.directory?(home)
            FileUtils.mkdir_p(home)
            FileUtils.copy('/etc/security/.profile', "#{home}/.profile")
            FileUtils.chown_R(user, pgrp, home)
            FileUtils.chmod(0750, home)
          end

          # Add user stanza to /etc/security/user
          begin
            chsec('-f', '/etc/security/user', '-s', user, '-a', 'SYSTEM=LDAP', '-a', 'registry=LDAP')
          rescue Puppet::ExecutionFailure
            fail "Could not add to /etc/security/user: #{user}"
            next
          end
        rescue 
          fail "Could not get home directory for #{user}"
          next
        end

      end
      notice("Added member #{user} for login.")
      next

    end

  end

  def destroy
    # This module doesn't manage deletes as users can be 
    # members of more than one group which allows access.
  end

end
