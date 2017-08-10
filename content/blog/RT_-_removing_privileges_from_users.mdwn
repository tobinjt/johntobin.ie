[[!meta date="08 Jan 2010 22:52:22 UTC"]]

In [work](http://www.scss.tcd.ie/), we use [Request Tracker
(RT)](http://bestpractical.com/rt) to manage help requests from users.  When
someone submits their first help request, RT creates a new user; sometimes, (I
don't know why), RT creates a privileged user whose email address is set to an
empty string.  I generally fix those users through the web interface, because
there are usually only a few, but yesterday there were over 100.  Faced with 8
mouse clicks and 8 keystrokes per user, I decided to directly manipulate the
database instead.  After reading <tt>User_Overlay.pm</tt>, and investigating the
database, I had a reasonable idea of what I needed to do: find users in the
Privileged group whose email
address is an empty string, set their email address, and remove their
privileged status.  The next question was what language to write it in?  I
wanted a quick solution, and it didn't have to be as robust as I would usually
require, so I wrote a quick shell script to do it:

    #!/bin/bash
    
    set -e
    
    mysql_cmd="mysql --skip-column-names rt3"
    priviliged_groupid=$( echo 'select Groups.id from Groups where Groups.Type = "Privileged";' | $mysql_cmd )
    echo 'select Users.id, Users.Name from Users, GroupMembers where GroupMembers.GroupId = '"$priviliged_groupid"' and GroupMembers.MemberId = Users.id and Users.EmailAddress = "";' \
        | $mysql_cmd \
        | awk '{print "delete from       GroupMembers where       GroupMembers.GroupId = '"$priviliged_groupid"' and       GroupMembers.MemberId = " $1 ";"}
               {print "delete from CachedGroupMembers where CachedGroupMembers.GroupId = '"$priviliged_groupid"' and CachedGroupMembers.MemberId = " $1 ";"}
               {print "update Users set Users.EmailAddress = \"" $2 "@tcd.ie\" where Users.id = " $1 ";"}' \
        | $mysql_cmd

It probably took longer to write this than it would have taken to use the web
interface, but it was more satisfying, and I learned something new.

[[!tag Request_Tracker sysadmin MySQL]]
