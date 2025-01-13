package utils

import "core:c"
import "core:os"
import "core:sys/posix"

//void randname(char* buf)
//{
//    struct timespec ts;
//    clock_gettime(CLOCK_REALTIME, &ts);
//    long r = ts.tv_nsec;
//    for (int i = 0; i < 6; ++i) {
//        buf[i] = 'A' + (r & 15) + (r & 16) * 2;
//        r >>= 5;
//    }
//}
//
//int create_shm_file(void)
//{
//    int retries = 100;
//    do {
//        char name[] = "/wl_shm-XXXXXX";
//        randname(name + sizeof(name) - 7);
//        --retries;
//        int fd = shm_open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
//        if (fd >= 0) {
//            shm_unlink(name);
//            return fd;
//        }
//    } while (retries > 0 && errno == EEXIST);
//    return -1;
//}
//
//int allocate_shm_file(size_t size)
//{
//    int fd = create_shm_file();
//    if (fd < 0)
//        return -1;
//    int ret;
//    do {
//        ret = ftruncate(fd, size);
//    } while (ret < 0 && errno == EINTR);
//    if (ret < 0) {
//        close(fd);
//        return -1;
//    }
//    return fd;
//}

allocate_shm_file :: proc(size: c.int32_t) -> posix.FD {
	using posix
	name: cstring = "/wl_shm-stuff"

	fd := shm_open(
		name,
		{O_Flag_Bits.RDWR, O_Flag_Bits.CREAT, O_Flag_Bits.EXCL},
		{Mode_Bits.IWUSR, Mode_Bits.IRUSR},
	)

	if (fd >= 0) {
		posix.shm_unlink(name)
	}
	if (fd < 0) {
		return -1
	}
	ret := posix.result.OK
	err := get_errno()

	for ret != result.FAIL && err == Errno.EINTR {
		ret = ftruncate(fd, posix.off_t(size))
		err = get_errno()
	}

	return fd
}
