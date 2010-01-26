# Define rubyforge tasks.

def task_rubyforge

  desc "Release packages (Rubyforge)"
  task :release do
    project.release
  end

  desc "Publish website (Rubyforge)"
  task :publish do
    project.publish
  end

end

#   # Publish
#
#   def publish
#     options = {}
#     options.update info.gather('rubyforge')
#     options.update info.gather('publish')
#
#     rubyforge.publish(options)
#   end
#
#   # Release options. This is a hash of options:
#   #
#   #     files        Files to release.
#   #     version      Package version.
#   #     package      Package name. Defaults to +project+.
#   #     release      Release name. Defaults to +version+.
#   #     date         Release Date. Defaults to +Time.now+.
#   #     processor    Processor type. Deafults to +Any+.
#   #     changelog    ChangeLog file.
#   #     notelog      Notes file.
#   #     is_public    Is this release public?
#   #
#
#   def release
#     options = {}
#     options.update info.gather('rubyforge')
#     options.update info.gather('release')
#     options.update info.select('version', 'changelog', 'notelog', 'processor'=>'arch')
#     options['files'] = Dir[File.join(info.package_store,"*#{options['version']}.*")]
#
#     rubyforge.release(options)
#   end
#
#   # Rubyforge object.
#
#   def rubyforge
# #     rubyforge_info = {
# #       'domain'   => rubyforge_info['domain'],
# #       'project'  => rubyforge_info['project'],
# #       'username' => rubyforge_info['username'],
# #       'group_id' => rubyforge_info['group_id'] || rubyforge_info['groupid'],
# #       'release'  => release_info,
# #       'publish'  => publish_info
# #     }
#
#     #rubyforge_info = {}
#     #rubyforge_info.update info.select('project')
#     #rubyforge_info.update info.gather('rubyforge')
#
#     domain   = info.rubyforge_domain
#     project  = info.rubyforge_project
#     username = info.rubyforge_username
#     group_id = info.rubyforge_group_id
#
#     #domain  ||= 'rubyforge.org'
#     project ||= info.project
#
#     @rubyforge ||= RubyForge.new(
#       :domain   => domain,
#       :project  => project,
#       :username => username,
#       :group_id => group_id
#     )
#   end

end
