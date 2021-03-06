# == Class: docker::service
#
# Class to manage the docker service daemon
#
# === Parameters
# [*tcp_bind*]
#   Which tcp port, if any, to bind the docker service to.
#
# [*socket_bind*]
#   Which local unix socket to bind the docker service to.
#
# [*socket_group*]
#   Which local unix socket to bind the docker service to.
#
# [*root_dir*]
#   Specify a non-standard root directory for docker.
#
# [*extra_parameters*]
#   Plain additional parameters to pass to the docker daemon
#
class docker::service (
  $docker_command   = $docker::docker_command,
  $service_name     = $docker::service_name,
  $tcp_bind         = $docker::tcp_bind,
  $socket_bind      = $docker::socket_bind,
  $socket_group     = $docker::socket_group,
  $service_state    = $docker::service_state,
  $service_enable   = $docker::service_enable,
  $root_dir         = $docker::root_dir,
  $extra_parameters = $docker::extra_parameters,
  $proxy            = $docker::proxy,
  $no_proxy         = $docker::no_proxy,
  $execdriver       = $docker::execdriver,
  $storage_driver   = $docker::storage_driver,
  $tmp_dir          = $docker::tmp_dir,
  $service_provider = $docker::service_provider,
  $service_binary   = $docker::service_binary,
  $service_start    = $docker::service_start,
  $service_stop     = $docker::service_stop,
  $service_status   = $docker::service_status,
  $service_restart  = $docker::service_restart,) {
  $extra_parameters_array = any2array($extra_parameters)

  case $::osfamily {
    'Debian' : {
      $hasstatus = false
      $hasrestart = false
      if $service_provider == 'upstart' {
        file { '/etc/init.d/docker':
          ensure => 'absent',
          notify => Service['docker'],
        }

        file { '/etc/default/docker':
          ensure  => present,
          force   => true,
          content => template('docker/etc/default/docker.erb'),
          notify  => Service['docker'],
        }
      }
    }
    'RedHat' : {
      $hasstatus = undef
      $hasrestart = undef

      if $service_provider == 'upstart' {
        file { '/etc/sysconfig/docker':
          ensure  => present,
          force   => true,
          content => template('docker/etc/sysconfig/docker.erb'),
          notify  => Service['docker'],
        }
      }
    }
    default  : {
      fail('Docker needs a RedHat or Debian based system.')
    }
  }

  service { 'docker':
    ensure     => $service_state,
    name       => $service_name,
    enable     => $service_enable,
    hasstatus  => $hasstatus,
    hasrestart => $hasrestart,
    provider   => $service_provider,
    binary     => $service_binary,
    start      => $service_start,
    stop       => $service_stop,
    status     => $service_status,
    restart    => $service_restart,
  }

}
