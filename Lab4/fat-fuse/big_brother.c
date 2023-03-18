#include "big_brother.h"
#include "fat_table.h"
#include "fat_util.h"
#include "fat_volume.h"
#include <stdio.h>
#include <string.h>

int bb_is_log_file_dentry(fat_dir_entry dir_entry) {
    return strncmp(LOG_FILE_BASENAME, (char *)(dir_entry->base_name), 3) == 0 &&
           strncmp(LOG_FILE_EXTENSION, (char *)(dir_entry->extension), 3) == 0;
}

int bb_is_log_filepath(char *filepath) {
    return strncmp(BB_LOG_FILE, filepath, 8) == 0;
}

int bb_is_log_dirpath(char *filepath) {
    return strncmp(BB_DIRNAME, filepath, 15) == 0;
}

// Searches for a cluster that could correspond to the bb directory and returns
// its index. If the cluster is not found, returns 0.

u32 search_bb_orphan_dir_cluster() {
    u32 bb_dir_start_cluster = 2;
    fat_volume vol = get_fat_volume();

    /*while (
        le32_to_cpu(
            (((const le32 *)vol->table->fat_map)[bb_dir_start_cluster]) !=
        FAT_CLUSTER_BAD_SECTOR) &&
    !fat_table_cluster_is_EOC(bb_dir_start_cluster)) { bb_dir_start_cluster++;
    }*/

    bool found = false;
    for (int i = 2; i < 10000 && !found; i++) {
        u32 clus = le32_to_cpu(
            ((const le32 *)vol->table->fat_map)[bb_dir_start_cluster]);
        if (clus == FAT_CLUSTER_BAD_SECTOR) {
            fat_file loaded_bb_dir = fat_file_init_orphan_dir(
                BB_DIRNAME, vol->table, bb_dir_start_cluster);
            GList *children = fat_file_read_children(loaded_bb_dir);
            if (children != NULL) {
                fat_dir_entry dentry = ((fat_file)(children->data))->dentry;
                if (bb_is_log_file_dentry(dentry)) {
                    found = true;
                    fat_tree_node root_node =
                        fat_tree_node_search(vol->file_tree, "/");
                    fat_tree_insert(vol->file_tree, root_node, loaded_bb_dir);
                    fat_tree_node bb_node =
                        fat_tree_node_search(vol->file_tree, BB_DIRNAME);
                    vol->file_tree = fat_tree_insert(
                        vol->file_tree, bb_node, ((fat_file)(children->data)));
                }
            }
            g_list_free(children);
        }
        bb_dir_start_cluster++;
    }

    if (!found) {
        bb_dir_start_cluster = 0;
    }
    printf("BB_DIR_START_CLUSTER: %i\n", bb_dir_start_cluster);

    return bb_dir_start_cluster;
}

// Creates the /bb directory as an orphan and adds it to the file tree as
//  child of root dir.

int bb_create_new_orphan_dir() {
    errno = 0;
    u32 marked_cluster;
    fat_volume vol = get_fat_volume();

    marked_cluster = fat_table_get_next_free_cluster(vol->table);

    fat_table_set_next_cluster(vol->table, marked_cluster,
                               FAT_CLUSTER_BAD_SECTOR);

    //  **** MOST IMPORTANT PART, DO NOT SAVE DIR ENTRY TO PARENT ****

    errno = bb_init_log_dir(marked_cluster);

    return -errno;
}

int bb_init_log_dir(u32 start_cluster) {
    errno = 0;
    fat_volume vol = NULL;
    fat_tree_node root_node = NULL;

    vol = get_fat_volume();

    // // Create a new file from scratch, instead of using a direntry like
    // normally done.
    fat_file loaded_bb_dir =
        fat_file_init_orphan_dir(BB_DIRNAME, vol->table, start_cluster);

    // // Add directory to file tree. It's entries will be like any other dir.
    root_node = fat_tree_node_search(vol->file_tree, "/");
    vol->file_tree = fat_tree_insert(vol->file_tree, root_node, loaded_bb_dir);

    return -errno;
}
