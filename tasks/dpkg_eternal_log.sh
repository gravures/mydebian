# dpkg_eternal_log Deby Task
#
# * task should set a doc variable to a one line docmentation string
# * do only one thing in a task
# * tasks should ideally not rely on programs or resources not
#   available on the base system
# * if a task needs uncommon .deb packages to be installed,
#   task should define a require variable as an array
#   of those dependencie's name
# * do_task and undo_task should be idempotent (calling those
#   functions multiple time should not hurt and result in the
#   same system state)
# * if a task couldn't be undone, undo_task() should not
#   be defined at all in this task file
#
requires=()
doc="set logrotate to never delete archived dpkg.log(s), keeping a history of packages instalation/deletion"

do_task() {
  cp /etc/logrotate.d/dpkg /etc/logrotate.d/dpkg.bak
  sed -r -i '/rotate/s/[0-9]+/-1/g' /etc/logrotate.d/dpkg
}

undo_task() {
  if [[ -e /etc/logrotate.d/dpkg.bak ]]; then
    mv /etc/logrotate.d/dpkg.bak /etc/logrotate.d/dpkg
  fi
}
