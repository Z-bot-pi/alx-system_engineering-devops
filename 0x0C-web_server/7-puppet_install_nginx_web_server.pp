# Install Nginx
package { 'nginx':
  ensure => installed,
}

# Create the index.html file with "Hello World!" content
file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}

# Configure Nginx to listen on port 80 and add the 301 redirect
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => template('nginx/default.erb'),
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Enable and start the Nginx service
service { 'nginx':
  ensure    => running,
  enable    => true,
  require   => File['/etc/nginx/sites-available/default'],
}

# Nginx configuration template (nginx/default.erb)
file { '/etc/puppetlabs/code/environments/production/modules/nginx/templates/default.erb':
  ensure => file,
  content => @("END"),
    server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
            try_files $uri $uri/ =404;
        }

        location = /redirect_me {
            return 301 https://www.github.com/z-bot-pi;
        }
    }
  | END
  require => Package['nginx'],
}
