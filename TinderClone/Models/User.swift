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
                username: "artlover456",
                name: "Jane",
                bio: """
                Hi, I'm Jane! 🎨 I'm a passionate artist and coffee enthusiast ☕. When I'm not at my easel, you can find me exploring the city's hidden gems and cozy cafes. I love immersing myself in the art scene, whether it's visiting a new museum exhibit 🖼️ or attending a local art fair. Let's explore the city together, share our favorite coffee spots, and maybe even sketch a bit while enjoying a latte. Looking forward to meeting someone who shares my love for creativity and adventure!
                """,
                pictureNames: ["profile_image_1", "profile_image_1_detail_1", "profile_image_1_detail_2"],
                age: 27,
                distance: 10,
                interests: ["Art", "Coffee", "Museum Hopping", "Sketching", "Watching TV", "Reading", "Yoga"]
            ),
            User(
                username: "foodie101",
                name: "Emily",
                bio: """
                Hello! I'm Emily, a food critic and amateur chef 👩‍🍳. My life revolves around food, whether it's critiquing the latest restaurant in town 🍽️ or whipping up a new recipe in my kitchen. I believe that food is a universal language that brings people together. Let's cook something amazing together, explore the best eateries, and enjoy a cozy night in with some Netflix 📺. If you love good food and great company, we'll get along just fine!
                """,
                pictureNames: ["profile_picture_0"],
                age: 25,
                distance: 15,
                interests: ["Cooking", "Food Critiquing", "Netflix & Chill", "Baking"]
            ),
            User(
                username: "coolguy123",
                name: "John",
                bio: """
                Hey, I'm John! 🏞️ I'm an outdoor enthusiast who loves hiking and seeking out new adventures. Whether it's climbing a challenging trail, camping under the stars 🌌, or rock climbing, I'm always up for a challenge. Fitness is a big part of my life, and I love pushing my limits. Looking for someone who enjoys the great outdoors and isn't afraid to get their hands dirty. Let's conquer the next mountain together!
                """,
                pictureNames: ["profile_picture_2"],
                age: 29,
                distance: 20,
                interests: ["Hiking", "Outdoor Adventures", "Fitness", "Camping", "Rock Climbing", "Trail Running"]
            ),
            User(
                username: "techguru789",
                name: "Alex",
                bio: """
                Hi, I'm Alex, your friendly neighborhood tech geek 🤓 and gamer 🎮. My passions include everything from coding the next big app 💻 to marathoning the latest video games. I'm always up-to-date with the latest in tech and love tinkering with new gadgets. I'm looking for someone who can share my enthusiasm for technology and gaming, and maybe join me for a co-op session or two. Let's build something great together!
                """,
                pictureNames: ["profile_picture_4"],
                age: 31,
                distance: 25,
                interests: ["Technology", "Gaming", "Coding", "Robotics"]
            ),
            User(
                username: "travelbug202",
                name: "Michael",
                bio: """
                Hi there! I'm Michael, a world traveler 🌍 and photographer 📷. My life is a constant adventure as I'm always planning my next trip ✈️. Capturing the beauty of different cultures and landscapes through my lens is my greatest passion. I'm also a blogger and love sharing my travel experiences with the world. If you're someone who enjoys exploring new places and cherishes every moment, let's embark on this journey together and create unforgettable memories.
                """,
                pictureNames: ["profile_picture_5"],
                age: 34,
                distance: 30,
                interests: ["Photography", "Blogging", "Playing the guitar"]
            )
        ]
    }
}
