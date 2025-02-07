import '../models/question.dart';

const Map<String, List<Question>> intros = {
  'Preferences': [ // 3 questions to just for preference e.g. do you post often?
    Question(
      question: 'Do you post often?',
      answers: ['Never', 'Not often', 'Often', 'Everyday'],
      correctness: [0, 1, 2, 3],
    ),
  ],
  'Assessment': [ // 5 questions to find skill level of person
    Question(
      question: 'From the list below, what is the most important thing to look out for before joining a Facebook group?', // facebook groups
      answers: ['Familiarity of group members', 'Frequency of uninteresting and spammy posts', 'Privacy settings, whether it is open or closer group', 'Group size'],
      correctness: [1, 3, 0, 2],
    ),
  ],
};