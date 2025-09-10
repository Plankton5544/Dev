#include <SFML/Graphics.hpp>

class GameObject {
    public:
        GameObject(sf::Vector2f position, sf::Vector2f size) {
            // Create a rectangle shape
            shape = new sf::RectangleShape(sf::Vector2f(size.x, size.y));

            // Set the position and size of the shape
            shape->setPosition(position);
            shape->setSize(size);
        }

        void render(sf::RenderWindow& window) {
            // Render the shape
            window.draw(*shape);
        }

    private:
        sf::RectangleShape* shape;
};




int main() {
    sf::RenderWindow window(sf::VideoMode({800u, 600u}), "CouchWars");
    GameObject gameObject(sf::Vector2f(100, 100), sf::Vector2f(50, 50));
    //Render Loop
    while (window.isOpen()) {
        // SFML 3 pollEvent() returns std::optional<sf::Event>
        // Handle events → Update game -> Draw -> Display
        while (auto event = window.pollEvent()) {
            // Use event.value() or just *event to access the event
            if (event->is<sf::Event::Closed>()) {
                window.close();
            }
        }

        window.clear();

        gameObject.render(window);
        window.display();
    }
}
