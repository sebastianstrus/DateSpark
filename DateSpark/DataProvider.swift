import Foundation

// MARK: - DataProvider
//
// A plain struct with a static shared instance. All methods are explicitly
// `nonisolated` (structs have no actor isolation by default), and the
// question list is a computed property — never a stored global — so Swift 6
// has nothing to infer and no @MainActor contamination can occur.

struct DataProvider: Sendable {

    static let shared = DataProvider()
    private init() {}

    // MARK: - Question list (computed, never stored globally)

    var allQuestions: [Question] {
        [
            // MARK: Ice Breakers
            Question(text: "What's a skill you're secretly proud of?",                     category: .iceBreakers, depth: .light),
            Question(text: "If your life had a theme song, what would it be?",              category: .iceBreakers, depth: .light),
            Question(text: "What's the most unusual thing in your home right now?",         category: .iceBreakers, depth: .light),
            Question(text: "What's your go-to comfort food after a bad day?",               category: .iceBreakers, depth: .light),
            Question(text: "If you could only eat one cuisine forever, what would it be?",  category: .iceBreakers, depth: .light),
            Question(text: "What's the last thing that made you laugh out loud?",           category: .iceBreakers, depth: .light),
            Question(text: "Are you more of a morning person or a night owl?",              category: .iceBreakers, depth: .light),
            Question(text: "What's a show you've rewatched more than three times?",         category: .iceBreakers, depth: .light),
            Question(text: "If you had to describe yourself in three words, what would they be?", category: .iceBreakers, depth: .medium),
            Question(text: "What's something you're better at than most people realise?",   category: .iceBreakers, depth: .medium),

            // MARK: Dreams & Goals
            Question(text: "What's one thing you want to accomplish in the next five years?",   category: .dreams, depth: .medium),
            Question(text: "If money were no object, how would you spend your days?",           category: .dreams, depth: .medium),
            Question(text: "What's a dream you've held onto since childhood?",                  category: .dreams, depth: .medium),
            Question(text: "Is there a version of yourself you're actively working toward?",    category: .dreams, depth: .deep),
            Question(text: "What legacy do you hope to leave behind?",                          category: .dreams, depth: .deep),
            Question(text: "What would you do if you knew you couldn't fail?",                  category: .dreams, depth: .medium),
            Question(text: "What does your ideal Saturday look like ten years from now?",       category: .dreams, depth: .medium),
            Question(text: "Is there a place in the world you feel called to live someday?",    category: .dreams, depth: .light),
            Question(text: "What's a goal you've been putting off that you know you should start?", category: .dreams, depth: .deep),
            Question(text: "Who inspires you the most and why?",                                category: .dreams, depth: .medium),

            // MARK: Childhood
            Question(text: "What's your favourite memory from childhood?",                      category: .childhood, depth: .light),
            Question(text: "What did you want to be when you grew up?",                         category: .childhood, depth: .light),
            Question(text: "Did you have a best friend growing up? What were they like?",       category: .childhood, depth: .medium),
            Question(text: "What's a tradition from your family you still carry with you?",     category: .childhood, depth: .medium),
            Question(text: "What's the most trouble you ever got into as a kid?",               category: .childhood, depth: .light),
            Question(text: "What book or movie defined your childhood?",                        category: .childhood, depth: .light),
            Question(text: "Was there a moment growing up that shaped who you are today?",      category: .childhood, depth: .deep),
            Question(text: "What's something your parents taught you that you're grateful for?", category: .childhood, depth: .medium),
            Question(text: "Did you have any weird childhood fears?",                           category: .childhood, depth: .light),
            Question(text: "What's a toy or game from your childhood most people wouldn't remember?", category: .childhood, depth: .light),

            // MARK: Deep Thoughts
            Question(text: "What's something you believe that most people disagree with?",     category: .deepThoughts, depth: .deep),
            Question(text: "How do you define happiness?",                                      category: .deepThoughts, depth: .deep),
            Question(text: "What's a moment that fundamentally changed your worldview?",        category: .deepThoughts, depth: .deep),
            Question(text: "Do you think people can truly change?",                             category: .deepThoughts, depth: .deep),
            Question(text: "What does love mean to you?",                                       category: .deepThoughts, depth: .deep),
            Question(text: "If you could have one conversation with your future self, what would you ask?", category: .deepThoughts, depth: .deep),
            Question(text: "What's the hardest lesson life has taught you?",                    category: .deepThoughts, depth: .deep),
            Question(text: "Do you think we create our own meaning, or is something larger at work?", category: .deepThoughts, depth: .deep),
            Question(text: "What's something you've changed your mind about in the last year?", category: .deepThoughts, depth: .medium),
            Question(text: "If you could relive one day of your life, which would it be and why?", category: .deepThoughts, depth: .deep),

            // MARK: Fun & Silly
            Question(text: "What's the weirdest food combination you secretly enjoy?",         category: .funAndSilly, depth: .light),
            Question(text: "If you were a cartoon character, who would you be?",               category: .funAndSilly, depth: .light),
            Question(text: "What's your most embarrassing moment you can laugh about now?",    category: .funAndSilly, depth: .light),
            Question(text: "If you had to survive a zombie apocalypse, what's your strategy?", category: .funAndSilly, depth: .light),
            Question(text: "Would you rather be able to fly or be invisible?",                 category: .funAndSilly, depth: .light),
            Question(text: "What's a conspiracy theory you find strangely compelling?",        category: .funAndSilly, depth: .light),
            Question(text: "If you opened a restaurant, what would it be called?",             category: .funAndSilly, depth: .light),
            Question(text: "What's the strangest dream you can remember?",                     category: .funAndSilly, depth: .light),
            Question(text: "If animals could talk, which would be the most annoying?",         category: .funAndSilly, depth: .light),
            Question(text: "What's your karaoke go-to song?",                                  category: .funAndSilly, depth: .light),

            // MARK: Travel
            Question(text: "What's the most beautiful place you've ever been?",                category: .travel, depth: .light),
            Question(text: "Do you prefer planned trips or spontaneous adventures?",           category: .travel, depth: .light),
            Question(text: "What's a place on your bucket list and why?",                      category: .travel, depth: .medium),
            Question(text: "What's the best meal you've ever had while travelling?",           category: .travel, depth: .light),
            Question(text: "Have you ever had a travel experience that changed you?",          category: .travel, depth: .deep),
            Question(text: "Beach, mountains, or city — where do you feel most at home?",     category: .travel, depth: .light),
            Question(text: "What's the worst travel story that became a great story?",         category: .travel, depth: .medium),
            Question(text: "If you could live anywhere for a year, where and why?",            category: .travel, depth: .medium),
            Question(text: "What culture or country fascinates you most?",                     category: .travel, depth: .medium),
            Question(text: "Would you ever pack up and move to a new country?",                category: .travel, depth: .medium),

            // MARK: Love & Life
            Question(text: "What does a healthy relationship look like to you?",               category: .loveAndLife, depth: .deep),
            Question(text: "What's something small that makes your day significantly better?", category: .loveAndLife, depth: .light),
            Question(text: "How do you show someone you care about them?",                     category: .loveAndLife, depth: .medium),
            Question(text: "What's a dealbreaker for you in a relationship?",                  category: .loveAndLife, depth: .medium),
            Question(text: "What's your love language?",                                       category: .loveAndLife, depth: .medium),
            Question(text: "What do you need most when you're going through something hard?",  category: .loveAndLife, depth: .deep),
            Question(text: "What's the kindest thing someone has ever done for you?",          category: .loveAndLife, depth: .medium),
            Question(text: "What's one thing you wish people understood about you?",           category: .loveAndLife, depth: .deep),
            Question(text: "What does a perfect evening look like to you?",                    category: .loveAndLife, depth: .light),
            Question(text: "Are you someone who falls slowly or all at once?",                 category: .loveAndLife, depth: .deep),

            // MARK: Hypothetical
            Question(text: "If you could have dinner with anyone, living or dead, who would it be?", category: .hypothetical, depth: .light),
            Question(text: "If you woke up as the opposite gender for a day, what's the first thing you'd do?", category: .hypothetical, depth: .light),
            Question(text: "If you could erase one memory, would you?",                        category: .hypothetical, depth: .deep),
            Question(text: "If you had 24 hours left on Earth, how would you spend it?",       category: .hypothetical, depth: .deep),
            Question(text: "Would you rather know when you're going to die, or how?",          category: .hypothetical, depth: .deep),
            Question(text: "If you could change one thing about how you were raised, what would it be?", category: .hypothetical, depth: .deep),
            Question(text: "If you could master any skill instantly, what would you choose?",  category: .hypothetical, depth: .light),
            Question(text: "If you could swap lives with someone for a week, who would it be?",category: .hypothetical, depth: .medium),
            Question(text: "Would you choose to live forever if you could?",                   category: .hypothetical, depth: .deep),
            Question(text: "If a movie was made about your life, what genre would it be?",     category: .hypothetical, depth: .light),
        ]
    }

    // MARK: - Query API

    func questions(for category: QuestionCategory) -> [Question] {
        allQuestions.filter { $0.category == category }
    }

    func randomQuestion(for category: QuestionCategory? = nil) -> Question? {
        if let category {
            return questions(for: category).randomElement()
        }
        return allQuestions.randomElement()
    }

    func favoriteQuestions(ids: Set<UUID>) -> [Question] {
        allQuestions.filter { ids.contains($0.id) }
    }

    func shuffledQuestions(for category: QuestionCategory) -> [Question] {
        questions(for: category).shuffled()
    }
}
