# Основная информация о ядре (можно подсмотреть в верхних строчках файла Makefile в корне исходников)
KERNEL_BASE_VERSION := 4.14.186

# Имя твоего дефконфига, который мы правили
KERNEL_DEFCONFIG := oplus6781_defconfig
KERNEL_ARCH := arm64

# Выставляем тулчейн Clang для Android 11
DEB_TOOLCHAIN := clang-android-10.0-r370808
BUILD_PATH := /usr/lib/llvm-android-10.0-r370808/bin
BUILD_CC := clang

# Настройки сборки для архитектур
DEB_BUILD_FOR := arm64

# Важнейшие аргументы командной строки ядра
KERNEL_BOOTIMAGE_CMDLINE := console=tty0 root=/dev/ram vmalloc=496M slub_max_order=0 slub_debug=O droidian.lvm.prefer

# Версия заголовка загрузочного образа (для Android 11 всегда равна 2)
KERNEL_BOOTIMAGE_VERSION := 2

# Автоматически собрать и прошить boot.img при установке пакета
FLASH_ENABLED := 1

# Поскольку у твоего телефона структура разделов современная (A/B или Dynamic Partitions), 
# мы оставляем это значение равным 0 (не старое Legacy)
FLASH_IS_LEGACY_DEVICE := 0

###########################################################################
# ВНИМАНИЕ: СЛЕДУЮЩИЕ ПАРАМЕТРЫ (OFFSETS) ТЕБЕ НУЖНО БУДЕТ ЗАПОЛНИТЬ САМОМУ!
# Их нужно достать из твоего родного, стокового boot.img от Android 11
# с помощью утилиты unpackbootimg.(я достал,не переживаете) 
###########################################################################

KERNEL_BOOTIMAGE_PAGE_SIZE := 2048
KERNEL_BOOTIMAGE_BASE_OFFSET := 0x40000000
KERNEL_BOOTIMAGE_KERNEL_OFFSET := 0x00080000
KERNEL_BOOTIMAGE_INITRAMFS_OFFSET := 0x07c80000
KERNEL_BOOTIMAGE_TAGS_OFFSET := 0x0bc80000
