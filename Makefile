# ========================================
# Configuration
# ========================================

NAME    = calc
ASM     = nasm
LD      = ld

ASMFLAGS = -f elf64 -g
LDFLAGS  =

SRC_DIR   = src
BUILD_DIR = build

SOURCES = \
    main.asm \
    control.asm \
    parse.asm \
    math.asm \
    ui.asm

OBJECTS = $(SOURCES:%.asm=$(BUILD_DIR)/%.o)

# ========================================
# Main rule
# ========================================

all: $(NAME)

$(NAME): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

# ========================================
# Assembling each file
# ========================================

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.asm
	mkdir -p $(BUILD_DIR)
	$(ASM) $(ASMFLAGS) -o $@ $<

# ========================================
# Cleaning
# ========================================

clean:
	rm -rf $(BUILD_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
