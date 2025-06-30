<!-- LTeX: enabled=false -->
# para.nvim
<!-- LTeX: enabled=true -->
<!-- toc -->
- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
<!-- tocstop -->

## Features

- Write your PARA method notes from inside Neovim

## Installation

```lua
-- lazy.nvim
{
	"tandetat/para.nvim",
},

-- packer
use {
	"tandetat/para.nvim",
}
```

## Configuration

```lua
-- default settings
require("para").setup {
	vault_dir = nil,
}
```

You should pass the parent directory to your PARA folders to `vault_dir`.

### Example Configuration

```lua
{
	"tandetat/para.nvim",
	event = 'VeryLazy',
	keys = {
      { '<leader>pp', '<cmd>ParaNewProject<cr>', desc = 'PARA' },
      { '<leader>pa', '<cmd>ParaNewArea<cr>', desc = 'PARA' },
      { '<leader>pr', '<cmd>ParaNewResource<cr>', desc = 'PARA' },
    },
	opts = {
		vault_dir = os.getenv('VAULT_DIR')
	}
}
```

## Usage

- `:ParaNewArea` to create a new note in Areas
- `:ParaNewProject` to create a new note in Projects
- `:ParaNewResource` to create a new note in Resources
