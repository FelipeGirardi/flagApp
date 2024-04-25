import Foundation
import SwiftUI

public extension ChallengesListView {
    final class ViewModel: ObservableObject {
        @Published var activeViewSetStates = Set<ChallengeInfo>()

        static var tntLaughVideoIDs: [String] {
            // Uncomment the following 3 lines if you want to show only a short video
//            #if DEBUG
//            return ["Yp5A-6j2-28"] // short video: Yp5A-6j2-28 / long video: 64HXxQSNTzc
//            #endif
            return deviceLanguage == "pt" ?
                [
                    "64HXxQSNTzc", "30NdZp3Kc-Q", "GJDNkVDGM_s", "Bca8krb7Vl0", "yBLdQ1a4-JI", "am1_JLFDFMw", "QNot4iC7K8s", "9x8dudqsoGA", "M5p9JO9JgvU", "1cB9qR2Pm70", "5qwYs6RbZs4", "FTcjzaqL0pE", "5OWOQF3dWi0", "0Haxy5PvCuk", "OR1MaKer5yw", "fn_yC0GzldU", "023o1_TgNjU", "fKIFt4rj_Q4", "iHlCW6dPfpc", "MTHBUoRuwcY", "9U3OyyDlsi0", "Aga4fAyYbvE", "kkwiQmGWK4c", "oVH3j31pV7Y", "9TlclWj1bCc", "gkfTIJQ36xc", "xzy82QpEMjk", "uY8nwNdz_9c", "eeQwPExFNRU", "FUrkziv1mmw", "cZYdSEUCVMI", "UpjztC6LWvI", "OhKVbUirB34", "wgUczLEUWkA", "3KG_Gspy0SI", "_TjtVC7TBRk", "XnWDlLdehgc", "tD46VAAHsNk", "eijMfo-GbH0", "W5IJcsp0QHI", "FR7FyvLMLOg", "eauQUkDyNiw", "NIJ5RiMAmNs", "7Lxqsu-7t1c", "nqwjC2NA5Dc", "6QyjZwOx9FU", "h5wv1CFnidw", "gcUvc25zNXk", "iiYLLVECoJM", "lwDEzBPx3zk", "yglvrsl617M", "eyPhoChMRM8", "z1RUGof93es", "pnLqyWJ8fcU", "YCaGYUIfdy4", "0eaBEs01heA", "UTd98iMBok", "MEFSjBpuh4A"
                ] : [
                    "unNRoBRzgS0", "0Haxy5PvCuk", "I1KijDNZxbA", "POiLhy3nfWQ", "P9VVa9NahSQ", "Ne6TDZgxv9w", "5OWOQF3dWi0", "_AtP7au_Q9w", "MQEhwzAdec4", "jA8W1PcTHJo", "ldhmieGyKUw", "FTcjzaqL0pE", "a4Y9bfQO8uE", "TuGgjfV3cbA", "EEGpgo6GdrE", "5CRZrY-IMMQ", "MtrvDyAs9RM", "uBbwZCRIILM", "W16THdQUku4", "Yp5A-6j2-28", "VQS4uUtm2kw", "5qwYs6RbZs4", "1cB9qR2Pm70", "M5p9JO9JgvU", "9x8dudqsoGA", "QNot4iC7K8s", "z3U0udLH974", "Vt6hIyZsRBw", "GJDNkVDGM_s", "5MkY-GBNzgE", "yFXU7o0fYII", "kkwiQmGWK4c", "oVH3j31pV7Y", "xzy82QpEMjk", "UpjztC6LWvI", "yBLdQ1a4-JI", "am1_JLFDFMw", "Lt1u6N7lueM", "wgUczLEUWkA", "sZr_XB2D4sk", "zOJBGZmCZYU", "co_D91v84eI", "eijMfo-GbH0", "b2ob56BuFeM", "cqaAduI50-k", "gNnOz9vtEcg", "ZA8OcknTkB0", "6n0qHB1Wqk4", "W5IJcsp0QHI", "CoYDuENIuec", "bCVkOqSDywI", "wPSRhvhpXjw", "kGAE8fux5FU", "qG-otGVaNPI", "mQxqx3QMnio", "3xENhMVbWhI", "FR7FyvLMLOg", "pCDl2YyWuTA", "5WBSoYIWQKo", "eauQUkDyNiw", "NIJ5RiMAmNs", "7Lxqsu-7t1c", "nqwjC2NA5Dc", "hZm93XX4kj0", "rbnQAfY-3n0", "rq6K5AUXEQ0", "xFFnntaqiFA", "QwITnvUo88I", "dchzG6txE7E", "pnLqyWJ8fcU", "kuS-xvE7T-0", "zhBYq1XfrK4", "oZFAcp-Qfbs", "YCaGYUIfdy4", "lXQI6L-sMTM", "0eaBEs01heA", "UTd98iMBok", "drUo2yx0uKU", "MEFSjBpuh4A"
                ]
        }

        static var tntBlinkVideoIDs: [String] {
            [
                "tbMpAWmstPM", "83CLX3N6-BE", "wqkt98QIirA"
            ]
        }

        var challengeInfos: [ChallengeInfo] =
        [
            ChallengeInfo(
                challengeName: NSLocalizedString("Try not to smile", comment: "Try not to smile"),
                challengeShortDescription: NSLocalizedString("TNTSmile cell description", comment: "React to a series of content without moving your mouth!"),
                challengeFullDescription: NSLocalizedString("TNTSmile main description", comment: "We will recognize your facial expressions..."),
                challengeImageString: "TNTsmile",
                challengeBackgroundImageName: "TNTsmileIntro-background",
                challengeHowToPlayDescription: NSLocalizedString("TNTSmile rules", comment: "As the timer goes off, a random video..."),
                challengeType: .TNTSmile,
                challengeVideoIDs: tntLaughVideoIDs
            ),
            ChallengeInfo(
                challengeName: NSLocalizedString("Try not to blink", comment: "Try not to blink"),
                challengeShortDescription: NSLocalizedString("TNTBlink cell description", comment: "React to a series of content without blinking!"),
                challengeFullDescription: NSLocalizedString("TNTBlink main description", comment: "We will recognize your facial expressions..."),
                challengeImageString: "TNTblink",
                challengeBackgroundImageName: "TNTblink-background",
                challengeHowToPlayDescription: NSLocalizedString("TNTBlink rules", comment: "As the timer goes off, a random video..."),
                challengeType: .TNTBlink,
                challengeVideoIDs: tntBlinkVideoIDs
            )
        ]

        public init() {}
    }
}

#if DEBUG
public extension ChallengesListView.ViewModel {
    static let mock = ChallengesListView.ViewModel()
}
#endif
