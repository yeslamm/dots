return {
    'CRAG666/code_runner.nvim',
    config = function()
        require('code_runner').setup {
            filetype = {
                python = 'python3 -u',
                java = { 'cd $dir &&', 'javac $fileName &&', 'java $fileNameWithoutExt' },
                -- Switched from 'gcc' to 'clang'
                c = {
                    'cd $dir &&',
                    'clang -Wall -Wextra -Werror -std=c11 $fileName -o $fileNameWithoutExt -lcs50 &&',
                    './$fileNameWithoutExt',
                },
            },
            mode = 'toggleterm',
        }
    end,
}
