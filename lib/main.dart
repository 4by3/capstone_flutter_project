import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:capstone_project/pages/intro_page.dart';
import 'package:capstone_project/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone_project/services/privacy_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// ThemeProvider class to manage theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themeKey = 'themeMode';

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  // Load the saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode =
        (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await PrivacyNotificationService().initNotifications();

  // Optionally, schedule a daily reminder for privacy settings
  await PrivacyNotificationService().scheduleDailyReminder(
    id: 1,
    title: 'Reminder to Update Privacy Settings',
    body:
        'Don\'t forget to check and update your privacy settings on Facebook.',
    hour: 9, // Example: 9 AM reminder
    minute: 0,
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Firebase initialized successfully');

  // Upload questions and features to Firestore
  await uploadQuestionsToFirestore();
  await uploadEasyQuestionsToFirestore();
  await uploadHardQuestionsToFirestore();
  await uploadFeaturesToFirestore();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> uploadQuestionsToFirestore() async {
  print('Starting uploadQuestionsToFirestore');
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('intro_questions').get();
    print('Intro questions snapshot docs count: ${snapshot.docs.length}');
    if (snapshot.docs.isNotEmpty) {
      print('Intro questions already exist in Firestore.');
      return;
    }

    final List<Map<String, dynamic>> introQuestions = [
      {
        'question':
            'How do you respond to unwanted interactions from strangers on Facebook?',
        'options': [
          'I ignore them completely',
          'I restrict their ability to contact me',
          'I use block or report tools when needed',
          'I don’t know what options are available'
        ],
        'answers': [1, 2, 3, 0]
      },
      {
        'question': 'How do you evaluate a Facebook group before joining?',
        'options': [
          'I check the group’s privacy level and rules',
          'I see if it’s active and matches my interests',
          'I join based on a friend’s recommendation',
          'I don’t think much about it, I just join'
        ],
        'answers': [3, 2, 1, 0]
      },
      {
        'question': 'How do you decide who can see your Facebook posts?',
        'options': [
          'I set a custom audience for sensitive posts',
          'I stick to “Friends” for most posts',
          'I leave it as “Public” for simplicity',
          'I don’t adjust it, I use the default setting'
        ],
        'answers': [3, 2, 0, 1]
      },
      {
        'question':
            'How cautious are you when engaging with posts from people you don’t know well?',
        'options': [
          'I often like or comment without much thought',
          'I engage if it’s public and seems safe',
          'I rarely interact unless I trust the person',
          'I avoid it entirely to protect my privacy'
        ],
        'answers': [0, 1, 2, 3]
      },
      {
        'question':
            'How do you handle tags from others on your Facebook timeline?',
        'options': [
          'I don’t manage tags, they show up as is',
          'I remove tags if I don’t like them',
          'I review tags occasionally but not always',
          'I enable tag review so I approve them first'
        ],
        'answers': [0, 2, 1, 3]
      },
    ];

    final CollectionReference questionsCollection =
        FirebaseFirestore.instance.collection('intro_questions');

    for (var question in introQuestions) {
      print('Uploading intro question: ${question['question']}');
      await questionsCollection.add({
        'question': question['question'],
        'options': question['options'],
        'answers': question['answers'],
      });
    }
    print('Intro questions uploaded successfully!');
  } catch (e) {
    print('Error uploading intro questions: $e');
  }
}

Future<void> uploadEasyQuestionsToFirestore() async {
  print('Starting uploadEasyQuestionsToFirestore');
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('easy_intro_questions')
        .get();
    print('Easy intro questions snapshot docs count: ${snapshot.docs.length}');
    if (snapshot.docs.isEmpty) {
      final Map<int, List<Map<String, dynamic>>> easyIntroQuestions = {
        0: [
          {
            'featureIndex': 0,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'Ayesha uses Facebook to keep in touch with friends, family, and coworkers. Recently, she received unwanted messages from a stranger. One friend keeps reacting strangely to her posts, and she also discovers someone using her name and photo on a fake account.',
            'question':
                'Ayesha gets spam messages from a stranger. What should she do to stop them?',
            'options': [
              'A) Reply and ask who they are',
              'B) Block the user',
              'C) Ignore the messages',
              'D) Send a message back'
            ],
            'answer': 'B) Block the user',
            'feedback':
                'Blocking someone stops all contact—messages, tags, and profile views.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question': 'What happens when Ayesha blocks someone?',
            'options': [
              'A) They can still comment on public posts',
              'B) They can still search her name',
              'C) They can’t see or interact with her',
              'D) They get a message saying they were blocked'
            ],
            'answer': 'C) They can’t see or interact with her',
            'feedback':
                'Blocked users can\'t see your profile or posts or interact with you on Facebook.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Ayesha finds a fake Facebook profile using her name and photo. What should she do?',
            'options': [
              'A) Block the fake account',
              'B) Report the fake account to Facebook',
              'C) Post about it on her timeline',
              'D) Message the account and ask them to stop'
            ],
            'answer': 'B) Report the fake account to Facebook',
            'feedback':
                'Reporting fake profiles helps Facebook investigate and remove impersonation.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Ayesha doesn\’t want one friend to see her posts but still wants to stay friends. What should she use?',
            'options': [
              'A) Unfriend them',
              'B) Restrict',
              'C) Block',
              'D) Turn off notifications'
            ],
            'answer': 'B) Restrict',
            'feedback': 'Restrict hides your posts.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question': 'What can a restricted friend see on Ayesha’s profile?',
            'options': [
              'A) All posts',
              'B) Only stories',
              'C) Public posts only',
              'D) Nothing at all'
            ],
            'answer': 'C) Public posts only',
            'feedback':
                'Restricted friends won’t know they’re restricted and can only view public posts.'
          },
        ],
        1: [
          {
            'featureIndex': 1,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'Amira joins a Facebook group called “Home Gardening Tips.” The group is full of helpful posts, and she enjoys learning from others. As she becomes more active, she starts noticing how group rules and admins help keep the group organized and respectful.',
            'question':
                'Amira wants to share a photo of her new plants. What should she check before posting? ',
            'options': [
              'A) If the group allows photo posts',
              'B) Her internet connection',
              'C) How many likes others got',
              'D) Her friend’s opinion'
            ],
            'answer': 'A) If the group allows photo posts',
            'feedback':
                'Always check the group rules to make sure your post follows what’s allowed. '
          },
          {
            'featureIndex': 1,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Someone in the gardening group posts an unrelated ad. What can the group admin do?',
            'options': [
              'A) Like the post',
              'B) Ignore it',
              'C) Remove the post and explain the rule',
              'D) Comment with a warning emoji'
            ],
            'answer': 'C) Remove the post and explain the rule',
            'feedback':
                'Admins can remove off-topic content and remind members of the group rules'
          },
          {
            'featureIndex': 1,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Amira wants to avoid posting the wrong kind of content again. What should she do?',
            'options': [
              'A) Ask the admin before posting',
              'B) Post and hope for the best',
              'C) Delete all her old posts',
              'D) Comment instead of posting'
            ],
            'answer': 'A) Ask the admin before posting',
            'feedback':
                'If unsure, asking the admin is a great way to stay safe and respectful.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Amira wants to join a private group about indoor plants. What does "private" mean? ',
            'options': [
              'A) Anyone can see posts',
              'B) Only members can see the posts',
              'C) The group has no rules',
              'D) Only admins can post'
            ],
            'answer': 'B) Only members can see the posts',
            'feedback':
                'Private groups limit visibility, only members can see posts and discussions.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question': 'What happens if a public group is changed to private?',
            'options': [
              'A) Old posts disappear',
              'B) All posts stay public',
              'C) Only new posts are private',
              'D) Old and new posts become visible only to members'
            ],
            'answer': 'D) Old and new posts become visible only to members',
            'feedback':
                'When a group becomes private, all past and future content becomes visible only to members.'
          },
        ],
        2: [
          {
            'featureIndex': 2,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'David often shares updates on Facebook—photos, work news, and personal thoughts. He wants to make sure the right people see the right posts. For example, he wants to share his new job with coworkers, a birthday memory with close friends, and a private journal entry just for himself.',
            'question':
                'David wants to share a post only with people on his friend list. Which setting should he use?',
            'options': ['A) Public', 'B) Friends', 'C) Only Me', 'D) Custom'],
            'answer': 'B) Friends',
            'feedback':
                'The "Friends" setting makes your post visible only to people you\'ve added as friends.'
          },
          {
            'featureIndex': 2,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'David wants to hide a post from a few specific people. What setting should he use?',
            'options': [
              'A) Friends ',
              'B) Friends Except…',
              'C) Public',
              'D) Only Me'
            ],
            'answer': 'B) Friends Except…',
            'feedback':
                '"Friends Except…" lets you stay connected but hide the post from selected people. '
          },
          {
            'featureIndex': 2,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'David wants to share a post with just his team at work. What setting helps him do that? ',
            'options': [
              'A) Close Friends',
              'B) Custom',
              'C) Public',
              'D) Friends'
            ],
            'answer': 'B) Custom',
            'feedback':
                'The "Custom" setting allows you to choose exactly who can or can\'t see your post. '
          },
          {
            'featureIndex': 2,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'David writes a personal journal post that he doesn’t want anyone else to see. What setting should he use?',
            'options': [
              'A) Public',
              'B) Friends',
              'C) Friends Except…',
              'D) Only Me'
            ],
            'answer': 'D) Only Me',
            'feedback':
                '"Only Me" hides the post from everyone else, it’s fully private.'
          },
          {
            'featureIndex': 2,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'David shared a post with “Friends,” but now wants to make it completely private. What should he do?',
            'options': [
              'A) Delete the post',
              'B) Turn off comments',
              'C) Change the audience to “Only Me”',
              'D) Tag fewer people'
            ],
            'answer': 'C) Change the audience to “Only Me”',
            'feedback':
                'You can update the audience on any of your posts at any time—even after posting.'
          },
        ],
        3: [
          {
            'featureIndex': 3,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'Nila was scrolling through Facebook when she saw a post from her friend Rehan celebrating his graduation. She liked the post, left a comment saying "Congrats!", and later replied to another friend’s comment on the same post. The next day, Rehan changed the post\'s privacy settings from "Public" to "Friends Only." ',
            'question':
                'What did Nila do when she liked and commented on Rehan\’s post? ',
            'options': [
              'A) Ignored the post',
              'B) Interacted with the post',
              'C) Changed the privacy',
              'D) Blocked Rehan'
            ],
            'answer': 'B) Interacted with the post',
            'feedback':
                'Liking, commenting, or replying to a post are all forms of interaction. '
          },
          {
            'featureIndex': 3,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Rehan\'s post was set to “Public.” Who could see Nila’s comment on it? ',
            'options': [
              'A) Only Rehan',
              'B) Only Nila\'s friends',
              'C) Anyone on Facebook',
              'D) Only mutual friends'
            ],
            'answer': 'C) Anyone on Facebook',
            'feedback':
                'Public posts are visible to everyone, including all comments and reactions.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Who controls who can see Nila’s comment on Rehan\’s post?',
            'options': [
              'A) Only Nila',
              'B) Only Rehan',
              'C) Nila’s friends',
              'D) Everyone who reacted to the post'
            ],
            'answer': 'B) Only Rehan',
            'feedback':
                'Rehan controls who can see the post and its comments, but Nila still owns her comment and can delete or edit it anytime. '
          },
          {
            'featureIndex': 3,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Nila sees a post about someone going through a hard time. What is the most thoughtful way to respond? ',
            'options': [
              'A) Use the “Haha” reaction',
              'B) Leave a kind comment',
              'C) Scroll past',
              'D) React with “Wow”'
            ],
            'answer': 'B) Leave a kind comment',
            'feedback':
                'Leaving a supportive comment shows empathy and kindness.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Why is it important to be careful when reacting to serious posts?',
            'options': [
              'A) Facebook might ban your account',
              'B) Reactions affect the post’s privacy',
              'C) People may misunderstand your intention',
              'D) Your reaction becomes private'
            ],
            'answer': 'C) People may misunderstand your intention',
            'feedback':
                'Using the wrong reaction on a serious post may hurt others, even if you didn’t mean to. '
          },
        ],
        4: [
          {
            'featureIndex': 4,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario': 'Your friend tags you in an unflattering photo.',
            'question':
                'Which feature lets you review this before it appears on your timeline?',
            'options': [
              'A) Tag review',
              'B) Privacy checkup',
              'C) News feed preferences',
              'D) Profile lock'
            ],
            'answer': 'A) Tag review',
            'feedback':
                'Tag review lets you ses and approve photos before they appear on your timeline.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 2,
            'scenarioNumber': 2,
            'scenario':
                'Someone tags you in a post and you have tag review turned on.',
            'question': 'What happens next?',
            'options': [
              'A) The tag shows up on your timeline right away',
              'B) Facebook removes the tag after 24 hours',
              'C) You receive a notification and can approve or ignore the tag',
              'D) The post is automatically hidden from everyone'
            ],
            'answer':
                'C) You receive a notification and can approve or ignore the tag',
            'feedback':
                'You will receive a notification, and the tag won\'t show up unless you approve it.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question': 'What does Facebook’s review feature do for you?',
            'options': [
              'A) Automatically tags your friends',
              'B) Hides all tag from profile',
              'C) Organize photo album',
              'D) Review post before they show on your timeline'
            ],
            'answer': 'D) Review post before they show on your timeline',
            'feedback':
                'Tag review helps you approve or deny tags before they appear on your profile.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question': 'Why might someone want to turn on tag review?',
            'options': [
              'A) To increase number of likes on their posts',
              'B) To block all friends from seeing their profile',
              'C) To have control over what appears on their timeline',
              'D) To automatically tag all their friends in photos'
            ],
            'answer': 'C) To have control over what appears on their timeline',
            'feedback':
                'Tag review helps you control your Facebook presence by letting you decide which tagged post appear on your profile.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Can you still be tagged in a post if you have tag review turned on?',
            'options': [
              'A) No all tags are blocked',
              'B) Yes, but you can review it before it shows on your timeline',
              'C) Only by close friends',
              'D) Only in photos, not in text posts'
            ],
            'answer':
                'B) Yes, but you can review it before it shows on your timeline',
            'feedback':
                'Tag review doesn\'t stops tag, it lets you decide wheter to show them on your timeline.'
          },
        ],
      };

      final CollectionReference easyQuestionsCollection =
          FirebaseFirestore.instance.collection('easy_intro_questions');

      // Clear existing collection to ensure fresh upload
      final easyDocs = await easyQuestionsCollection.get();
      for (var doc in easyDocs.docs) {
        await doc.reference.delete();
      }

      for (var featureIndex in easyIntroQuestions.keys) {
        for (var question in easyIntroQuestions[featureIndex]!) {
          print(
              'Uploading easy intro question for feature $featureIndex: ${question['question']}');
          await easyQuestionsCollection.add({
            'featureIndex': question['featureIndex'],
            'questionOrder': question['questionOrder'],
            'scenarioNumber': question['scenarioNumber'],
            'scenario': question['scenario'],
            'question': question['question'],
            'options': question['options'],
            'answer': question['answer'],
            'feedback': question['feedback'],
          });
        }
      }
      print('Easy intro questions uploaded successfully!');
    } else {
      print('Easy intro questions already exist in Firestore.');
    }
  } catch (e) {
    print('Error uploading easy intro questions: $e');
  }
}

Future<void> uploadHardQuestionsToFirestore() async {
  print('Starting uploadHardQuestionsToFirestore');
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('hard_intro_questions')
        .get();
    print('Hard intro questions snapshot docs count: ${snapshot.docs.length}');
    if (snapshot.docs.isEmpty) {
      final Map<int, List<Map<String, dynamic>>> hardIntroQuestions = {
        0: [
          {
            'featureIndex': 0,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'You’ve been using Facebook for several years and have accumulated a large network. Recently, you have encountered some complex privacy challenges and need to manage interactions with various connections while maintaining a professional online presence.',
            'question': 'When you restrict someone, which is FALSE?',
            'options': [
              'A) They only see things you post publicly',
              'B) They can still leave comments',
              'C) Other friends can see their comments',
              'D) They find out you restricted them'
            ],
            'answer': 'D) They find out you restricted them',
            'feedback': 'People don’t know when you restrict them on Facebook.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'A member keeps sharing misleading health information despite warnings. What’s the best response?',
            'options': [
              'A) Block them from all your personal account',
              'B) Report the content and provide specific details about the violation',
              'C) Restrict them so they can still participate but with limitations',
              'D) Wait for other members to report the content'
            ],
            'answer':
                'B) Report the content and provide specific details about the violation',
            'feedback':
                'Providing details helps Facebook review and moderate the content effectively.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 3,
            'scenarioNumber': 2,
            'scenario':
                'A competitor’s employee is harassing your business page.',
            'question': 'What offers the best protection?',
            'options': [
              'A) Block them from your personal profile only',
              'B) Remove their comments manually',
              'C) Report their behavior and block them from both your page and profile',
              'D) Restrict them so they don’t know they are being limited'
            ],
            'answer':
                'C) Report their behavior and block them from both your page and profile',
            'feedback':
                'Reporting and blocking prevent their access to both your page and profile.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 4,
            'scenarioNumber': 3,
            'scenario':
                'You discovered someone hacked into your account and sent messages to your friends asking for money.',
            'question': 'What is the best response?',
            'options': [
              'A) Block the recipients of the messages',
              'B) Delete the messages and apologize',
              'C) Change your password, enable two factor authentication, then report the unauthorized access to Facebook',
            ],
            'answer':
                'C) Change your password, enable two factor authentication, then report the unauthorized access to Facebook',
            'feedback':
                'Secure your account first, then report to prevent future breaches.'
          },
          {
            'featureIndex': 0,
            'questionOrder': 5,
            'scenarioNumber': 4,
            'scenario': 'A friend’s account is tagging people in crypto posts.',
            'question': 'How can you protect the most people?',
            'options': [
              'A) Unfollow their account',
              'B) Ignore it and hope it stops',
              'C) Block the account immediately',
              'D) Check with your friend first. If it’s not them report and warn others'
            ],
            'answer':
                'D) Check with your friend first. If it’s not them report and warn others',
            'feedback':
                'Reporting helps Facebook investigate, while warning friends protects your network.'
          },
        ],
        1: [
          {
            'featureIndex': 1,
            'questionOrder': 1,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'As an admin of a large hobby group, what is the MOST effective way to handle a member who repeatedly posts off-topic political content?',
            'options': [
              'A) Delete the post without explanation',
              'B) Create a specific rule about off-topic posting and enforce it with a warning system',
              'C) Block them immediately without warning',
              'D) Ignore it'
            ],
            'answer':
                'B) Create a specific rule about off-topic posting and enforce it with a warning system',
            'feedback':
                'Clear rules with fair enforcement help maintain group focus while giving members a chance to correct behavior, creating a better experience for everyone.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 2,
            'scenarioNumber': 1,
            'scenario': 'Your photography group has 5,000 members.',
            'question': 'How can you maintain quality content?',
            'options': [
              'A) Limit new member requests',
              'B) Switch to a "members only" format',
              'C) Approve all posts manually yourself',
              'D) Add trusted moderators and create posting guidelines'
            ],
            'answer': 'D) Add trusted moderators and create posting guidelines',
            'feedback':
                'Distributing moderation responsibilities and setting rules helps manage growth while ensuring quality.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 3,
            'scenarioNumber': 2,
            'scenario':
                'A heated argument erupts between two prominent group members.',
            'question': 'What is the most effective admin response?',
            'options': [
              'A) Temporarily mute the thread and message both parties privately',
              'B) Ban both members',
              'C) Let them resolve it themselves',
              'D) Take sides with the member who’s right'
            ],
            'answer':
                'A) Temporarily mute the thread and message both parties privately',
            'feedback':
                'Cooling down conflicts privately preserves group harmony while respecting both members.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'Which group setting creates the HIGHEST privacy for sensitive discussions?',
            'options': [
              'A) Private group',
              'B) Private + hidden from search',
              'C) Public with post approval',
              'D) Members only group'
            ],
            'answer': 'B) Private + hidden from search',
            'feedback':
                'This ensures the group won’t appear in searches, and only members can see content.'
          },
          {
            'featureIndex': 1,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'What is the biggest security risk when converting a private group to public?',
            'options': [
              'A) New member requests',
              'B) Admin privileges are reset',
              'C) Group name changes',
              'D) All previous posts become visible to everyone'
            ],
            'answer': 'D) All previous posts become visible to everyone',
            'feedback':
                'Changing privacy settings applies to past content, which may expose previously private conversations.'
          },
        ],
        2: [
          {
            'featureIndex': 2,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'You’re building your personal brand online and want to keep your Facebook presence both professional and private. With friends, coworkers, clients, and family all in one place, managing who sees what has become a must. You now use audience settings to carefully control your posts. ',
            'question':
                'You’re sharing a post related to your work or industry. What setting helps you share it with colleagues while hiding it from others? ',
            'options': [
              'A) Friends',
              'B) Friends Except… ',
              'C) Public',
              'D) Only Me'
            ],
            'answer': 'B) Friends Except… ',
            'feedback':
                '“Friends Except…” lets you hide your post from selected people without them knowing. '
          },
          {
            'featureIndex': 2,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'You shared your job promotion using “Custom” to target a specific list. A tagged friend shares it. Who can now see the post?',
            'options': [
              'A) Everyone',
              'B) Only the original custom audience',
              'C) Only mutual friends',
              'D) Everyone except those tagged'
            ],
            'answer': 'B) Only the original custom audience',
            'feedback':
                'Custom settings still control visibility, even when someone shares your post.'
          },
          {
            'featureIndex': 2,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'You want to hide a post from your boss and a few family members without unfriending them. What’s the best option? ',
            'options': [
              'A) Public',
              'B) Hide from Timeline',
              'C) Friends Except…',
              'D) Close Friends'
            ],
            'answer': 'C) Friends Except…',
            'feedback':
                'Friends Except… allows you to silently exclude selected people from specific posts.'
          },
          {
            'featureIndex': 2,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'You switch a post’s visibility from Public to Only Friends. Who loses access to it?',
            'options': [
              'A) All users',
              'B) Your followers',
              'C) People not on your friends list',
              'D) Mutual friends'
            ],
            'answer': 'C) People not on your friends list',
            'feedback':
                'Switching a post’s visibility from Public to Only Friends restricts access to only your approved friends, blocking everyone else immediately.'
          },
          {
            'featureIndex': 2,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'A stranger screenshot your public post and shares it out of context. How can you prevent this in the future?',
            'options': [
              'A) Make future posts Friends Only or Custom ',
              'B) Report the screenshot',
              'C) Delete your Facebook account',
              'D) Ask them to take it down nicely'
            ],
            'answer': 'A) Make future posts Friends Only or Custom ',
            'feedback':
                'Limiting your audience to trusted groups reduces the chances of content misuse. '
          },
        ],
        3: [
          {
            'featureIndex': 3,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'Mark comments on a public post made by a friend. Later, the friend turns on “Review Comments”, which means all comments need approval before appearing.',
            'question':
                'What happens to Mark’s comment after the setting is on?',
            'options': [
              'A) Auto visible',
              'B) Hidden until approved',
              'C) Gone',
              'D) Mutual only'
            ],
            'answer': 'B) Hidden until approved',
            'feedback':
                'With comment review on, all comments need approval—including Mark’s.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 2,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'If a user reacts to a post shared with a limited audience, who can see that reaction?',
            'options': [
              'A) Everyone',
              'B) Selected friends',
              'C) Only mutual friends',
              'D) The user’s entire friend list'
            ],
            'answer': 'B) Selected friends',
            'feedback':
                'Reactions follow post privacy. If the post is limited, only selected friends can see your interaction.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 3,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'What happens to a reply if the original comment is hidden?',
            'options': [
              'A) Becomes a new post',
              'B) Reply stays',
              'C) Reply disappears',
              'D) Only hidden from commenter'
            ],
            'answer': 'C) Reply disappears',
            'feedback':
                'Likes and replies follow the post’s privacy. Hidden posts hide all interactions.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'A user changes a post from "Friends Only" to "Only Me." What happens to a friend’s comment?',
            'options': [
              'A) Still visible to commenter',
              'B) Deleted',
              'C) Moved to archive',
              'D) Only the person who shared the post can see it'
            ],
            'answer': 'D) Only the person who shared the post can see it',
            'feedback':
                'When changed to “Only Me,” even comments from others are hidden from everyone else.'
          },
          {
            'featureIndex': 3,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'A user comments on a "Friends Only". The post is now made Public. Who can see the comment?',
            'options': [
              'A) Everyone',
              'B) No one',
              'C) Only to mutual friends',
              'D) Only with approval'
            ],
            'answer': 'A) Everyone',
            'feedback':
                'When a post becomes Public, comments also become visible to everyone.'
          },
        ],
        4: [
          {
            'featureIndex': 4,
            'questionOrder': 1,
            'scenarioNumber': 1,
            'scenario':
                'Sophie goes to a party, and a friend uploads a bunch of photos, tagging her in several of them. Luckily, Sophie has Tag Review turned on—so she can approve or decline tags before they appear on her profile. But Sophie doesn\’t check for hours.',
            'question': 'What happens to the tagged photos?',
            'options': [
              'A) Tags stay hidden',
              'B) Tags auto-approve',
              'C) Photos disappear',
              'D) Friends can’t see them'
            ],
            'answer': 'A) Review the tag',
            'feedback':
                'Reviewing the tag lets you control visibility before it’s posted.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 2,
            'scenarioNumber': 1,
            'scenario':
                'Someone tags you in a post and you have tag review turned on.',
            'question': 'What happens next?',
            'options': [
              'A) The tag shows up on your timeline right away',
              'B) Facebook removes the tag after 24 hours',
              'C) You receive a notification and can approve or ignore the tag',
              'D) The post is automatically hidden from everyone'
            ],
            'answer':
                'C) You receive a notification and can approve or ignore the tag',
            'feedback':
                'You will receive a notification, and the tag won\'t show up unless you approve it.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 3,
            'scenarioNumber': 1,
            'scenario':
                'You receive a tag from Sophie in a public post that you don’t want everyone to see.',
            'question':
                'If Sophie removes a tag from a post, who can still see the post?',
            'options': [
              'A) Enable tag review',
              'B) Block Sophie',
              'C) Report the tag',
              'D) Do nothing'
            ],
            'answer': 'A) Enable tag review',
            'feedback':
                'Enabling tag review requires your approval for all tags.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 4,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'You receive a tag from Sophie in a public post that you don’t want everyone to see.',
            'options': [
              'A) Shared audience',
              'B) Only Sophie',
              'C) Tagged friends only',
              'D) No one'
            ],
            'answer': 'A) Shared audience',
            'feedback':
                'Removing a tag just unlinks your name—it doesn’t delete or hide the post.'
          },
          {
            'featureIndex': 4,
            'questionOrder': 5,
            'scenarioNumber': null,
            'scenario': '',
            'question':
                'If a post’s privacy is changed after tagging, what happens to the tag?',
            'options': [
              'A) Tag is removed',
              'B) Stays as originally set',
              'C) Becomes hidden',
              'D) Follows new privacy settings'
            ],
            'answer': 'D) Follows new privacy settings',
            'feedback':
                'Tags follow the post\'s privacy settings. If a post becomes private, the tag will also be hidden from others.'
          },
        ],
      };

      final CollectionReference hardQuestionsCollection =
          FirebaseFirestore.instance.collection('hard_intro_questions');

      // Clear existing collection to ensure fresh upload
      final hardDocs = await hardQuestionsCollection.get();
      for (var doc in hardDocs.docs) {
        await doc.reference.delete();
      }

      for (var featureIndex in hardIntroQuestions.keys) {
        for (var question in hardIntroQuestions[featureIndex]!) {
          print(
              'Uploading hard intro question for feature $featureIndex: ${question['question']}');
          await hardQuestionsCollection.add({
            'featureIndex': question['featureIndex'],
            'questionOrder': question['questionOrder'],
            'scenarioNumber': question['scenarioNumber'],
            'scenario': question['scenario'],
            'question': question['question'],
            'options': question['options'],
            'answer': question['answer'],
            'feedback': question['feedback'],
          });
        }
      }
      print('Hard intro questions uploaded successfully!');
    } else {
      print('Hard intro questions already exist in Firestore.');
    }
  } catch (e) {
    print('Error uploading hard intro questions: $e');
  }
}

Future<void> uploadFeaturesToFirestore() async {
  print('Starting uploadFeaturesToFirestore');
  try {
    final CollectionReference featuresCollection =
        FirebaseFirestore.instance.collection('features');

    // Check if features with required indices already exist
    final snapshot = await featuresCollection.get();
    print('Features snapshot docs count: ${snapshot.docs.length}');

    // Map existing documents by index for efficient lookup
    final existingFeatures = <int, DocumentSnapshot>{};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('index')) {
        existingFeatures[data['index'] as int] = doc;
      }
    }
    print('Existing features with index: ${existingFeatures.keys.toList()}');

    // Define features data with index
    final List<Map<String, dynamic>> featuresData = [
      {
        'index': 0,
        'name': 'Block, Restrict, Report Usage',
        'score': 0,
        'started': 0,
        'video':
            'https://ia800802.us.archive.org/2/items/block-restrict-report-usage-2/Block%2C%20Restrict%2C%20Report%20Usage2.mp4',
        'description':
            'Learn how to manage unwanted interactions with blocking, restricting, and reporting tools.',
      },
      {
        'index': 1,
        'name': 'Facebook Groups',
        'score': 0,
        'started': 0,
        'video':
            'https://ia800802.us.archive.org/2/items/block-restrict-report-usage-2/Facebook%20Group%20Privacy%20Settings%20%281%29.mp4',
        'description':
            'Discover privacy controls for joining, participating in, and managing Facebook Groups.',
      },
      {
        'index': 2,
        'name': 'Audience Setting for Posts',
        'score': 0,
        'started': 0,
        'video':
            'https://ia800802.us.archive.org/2/items/block-restrict-report-usage-2/Facebook%20Audience%20Settings%20%281%29.mp4',
        'description':
            'Control who sees your posts with audience selection tools.',
      },
      {
        'index': 3,
        'name': 'Interaction on Others\' Posts',
        'score': 0,
        'started': 0,
        'video':
            'https://ia800802.us.archive.org/2/items/block-restrict-report-usage-2/Interaction.mp4',
        'description':
            'Manage your visibility when interacting with content from other users.',
      },
      {
        'index': 4,
        'name': 'Tag Review and Settings',
        'score': 0,
        'started': 0,
        'video':
            'https://ia800802.us.archive.org/2/items/block-restrict-report-usage-2/Tag_Review.mp4',
        'description':
            'Learn how to review and control when others tag you in posts or photos.',
      },
    ];

    // Upload or update features
    for (var feature in featuresData) {
      final index = feature['index'] as int;
      print('Processing feature: ${feature['name']} (index: $index)');

      if (existingFeatures.containsKey(index)) {
        // Update existing document if necessary
        final doc = existingFeatures[index]!;
        final currentData = doc.data() as Map<String, dynamic>;
        if (currentData['name'] != feature['name'] ||
            currentData['video'] != feature['video'] ||
            currentData['description'] != feature['description']) {
          await doc.reference.set(feature, SetOptions(merge: true));
          print('Updated feature with index $index');
        } else {
          print('Feature with index $index is up-to-date');
        }
      } else {
        // Add new document with deterministic ID
        await featuresCollection.doc('feature_$index').set(feature);
        print('Uploaded new feature with index $index');
      }
    }
    print('Features uploaded/updated successfully!');
  } catch (e) {
    print('Error uploading features: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Check if the intro page should be shown
  Future<bool> _checkIntroPage() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if user has completed intro summary
    final introCompleted = prefs.getBool('introCompleted') ?? false;
    // If true => skip IntroPage
    return !introCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.blue[50],
            textTheme: GoogleFonts.dmSansTextTheme(
              Theme.of(context).textTheme,
            ),
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 24, 53, 98),
              onPrimary: Colors.white,
              secondary: Colors.blue[100]!,
              background: Colors.blue[50]!,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color.fromARGB(255, 0, 0, 0),
            textTheme: GoogleFonts.dmSansTextTheme(
              Theme.of(context).textTheme.apply(
                    bodyColor: Colors.white70,
                    displayColor: Colors.white,
                  ),
            ),
            colorScheme: ColorScheme.dark(
              primary: const Color.fromARGB(255, 24, 53, 98),
              onPrimary: Colors.white,
              secondary: Colors.grey[800]!,
              background: Colors.grey[900]!,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 53, 98),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          themeMode: themeProvider.themeMode,
          home: FutureBuilder<bool>(
            future: _checkIntroPage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data == true) {
                return const IntroPage();
              } else {
                return const HomePage();
              }
            },
          ),
        );
      },
    );
  }
}
