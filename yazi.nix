{ ... }:
{
    programs.yazi = {
        enable = true;
        settings.yazi = {
            manager.show_hidden = true;
            sort_dir_first = true;
            sort_by = "natural";
        };
    };
}
