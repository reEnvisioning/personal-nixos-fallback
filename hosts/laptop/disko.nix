{
  disk.main = {
    type = "disk";
    # Replace with the laptop's stable /dev/disk/by-id NVMe path before installation.
    device = "/dev/disk/by-id/nvme-LAPTOP_DISK_ID";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "luks";
            name = "crypt-root";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
