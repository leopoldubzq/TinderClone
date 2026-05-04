import Foundation

struct User: Identifiable, Hashable {
    let id: UUID = UUID()
    let username: String
    let name: String
    let bio: String
    let pictureNames: [String]
    let age: Int
    let distance: Int
    let interests: [String]
    
    var profilePicture: String {
        guard !pictureNames.isEmpty else { return "" }
        return pictureNames.first!
    }
    
    static var mockData: [Self] {
        [
            User(
                username: "ironman",
                name: "Tony Stark",
                bio: """
                Genius, billionaire, playboy, philanthropist. 🏗️ When I'm not saving the world in my high-tech suit, I'm pushing the boundaries of technology and innovation. Love fast cars, good whiskey 🥃, and a good challenge. If you can keep up with my wit and intelligence, we’ll get along just fine. Just don’t try to hack my suit. 🚀
                """,
                pictureNames: ["tony_stark_1", "tony_stark_2", "tony_stark_3"],
                age: 48,
                distance: 5,
                interests: ["Technology", "Engineering", "Flying", "AI Development", "Saving the World", "Leadership"]
            ),
            User(
                username: "spidey",
                name: "Peter Parker",
                bio: """
                Just your friendly neighborhood Spider-Man! 🕷️ Swinging through life one web at a time. By day, I’m a photographer and student 📸, but when duty calls, I’m out there keeping the city safe. I love science, bad puns, and stopping bad guys. Looking for someone to share a slice of pizza 🍕 and a good conversation about superheroes.
                """,
                pictureNames: ["peter_parker_1", "peter_parker_2", "peter_parker_3"],
                age: 18,
                distance: 10,
                interests: ["Photography", "Science", "Swinging Around", "Pizza", "Crime Fighting", "Engineering"]
            ),
            User(
                username: "godofthunder",
                name: "Thor Odinson",
                bio: """
                Son of Odin, God of Thunder ⚡ and protector of the realms. Whether I’m wielding Mjolnir or Stormbreaker, I’m always ready for battle. I enjoy feasting 🍖, storytelling, and a good fight. If you can handle a little lightning and appreciate the art of combat, we’ll get along splendidly. Let us share a drink and tales of glory!
                """,
                pictureNames: ["thor_1", "thor_2", "thor_3"],
                age: 1500,
                distance: 15,
                interests: ["Battles", "Feasting", "Drinking", "Thunderstorms", "Protecting Asgard", "Leadership"]
            ),
            User(
                username: "blackwidow",
                name: "Natasha Romanoff",
                bio: """
                Ex-assassin, top-tier spy, and expert in hand-to-hand combat. 🔥 I can take down enemies before they even see me coming. When I'm not on a mission, I enjoy a quiet drink, martial arts, and keeping my past where it belongs. Looking for someone who can handle a bit of mystery and isn’t afraid of a strong woman.
                """,
                pictureNames: ["black_widow_1", "black_widow_2", "black_widow_3"],
                age: 35,
                distance: 20,
                interests: ["Espionage", "Martial Arts", "Tactical Strategy", "Motorcycles", "Red Room Secrets", "Crime Fighting"]
            ),
            User(
                username: "captain",
                name: "Steve Rogers",
                bio: """
                A soldier out of time, still adjusting to the modern world. 🏅 I believe in honor, justice, and doing the right thing, no matter the cost. If you enjoy long walks (or runs) in Washington D.C., 1940s music 🎶, and standing up for what’s right, we’ll get along. Let’s go grab a coffee and talk about what makes a hero.
                """,
                pictureNames: ["steve_rogers_1", "steve_rogers_2", "steve_rogers_3"],
                age: 105,
                distance: 8,
                interests: ["Justice", "Training", "Leadership", "Shield Throwing", "Dancing", "Martial Arts"]
            )
        ]
    }
}
