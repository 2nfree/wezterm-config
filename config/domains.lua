return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   -- ssh_domains = {},
   ssh_domains = {
      -- yazi's image preview on Windows will only work if launched via ssh from WSL
      {
         name = 'Cloud',
         remote_address = '119.45.166.87',
         username = 'root',
         timeout = 60,
         multiplexing = 'None',
         assume_shell = 'Posix',
         ssh_option = {
            identityfile = 'C:\\Users\\komorebi.xue\\.ssh\\id_rsa',
         }
      }
   },

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = {
      {
         name = 'WSL:Arch',
         distribution = 'Arch',
         username = 'komorebi',
         default_cwd = '/home/komorebi',
         default_prog = { 'zsh', '-l' },
      },
   },
}
