import '../models/question.dart';

const Map<String, List<Question>> features = {
  'Block, Restrict, and Report Usage': [
    Question(
      question: 'A user you don’t know has sent you multiple inappropriate messages and it’s making you uncomfortable.\nDo you:',
      answers: ['Ignore the message', 'Block the user so they cannot contact you again', 'Respond to the message and ask them to stop', 'Report the user for inappropriate behaviour'],
      correctness: [1, 1, 0, 1],
    ),
    Question(
      question: 'You find a Facebook profile using your name and photos to impersonate you and send messages to people.\nDo you:',
      answers: ['Ignore it assuming it will go away', 'Send a message to the profile asking them to stop the impersonation', 'Report the profile to Facebook for impersonation', 'Post about it publicly to let the others know'],
      correctness: [0, 0, 1, 1],
    ),
  ],
  'Audience Setting for Posts ': [
    Question(
      question: 'You post a photo from a family gathering on your profile. A colleague comments on the post, mentioning details about your workplace.\nDo you:',
      answers: ['Leave it public to let everyone enjoy the post', 'Change the audience to "Friends Only"', 'Use the custom audience option to exclude colleagues', 'Delete the comment to avoid workplace-related exposure'],
      correctness: [0, 1, 1, 1],
    ),
  ],
};