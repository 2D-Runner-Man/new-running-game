# name_input_screen.py
import pygame

def name_input_screen(screen, font):
    """Ask the player to input their name."""
    input_box = pygame.Rect(screen.get_width() // 2 - 150, screen.get_height() // 2 - 25, 300, 50)
    active, color, text = False, pygame.Color('lightskyblue'), ""

    while True:
        screen.fill((32, 32, 32))  # Black background
        # screen.fill((255, 255, 255))  # White background
        instruction_text = font.render("Enter your name and press Enter:", True, (255, 255, 255))
        screen.blit(instruction_text, (screen.get_width() // 2 - 200, screen.get_height() // 2 - 100))
        pygame.draw.rect(screen, color, input_box, 2)
        screen.blit(font.render(text, True, (255, 255, 255)), (input_box.x + 10, input_box.y + 10))

        pygame.display.flip()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                return None
            if event.type == pygame.MOUSEBUTTONDOWN:
                active = input_box.collidepoint(event.pos)
                color = pygame.Color('dodgerblue') if active else pygame.Color('lightskyblue')
            if event.type == pygame.KEYDOWN and active:
                if event.key == pygame.K_RETURN:
                    return text
                elif event.key == pygame.K_BACKSPACE:
                    text = text[:-1]
                else:
                    text += event.unicode
