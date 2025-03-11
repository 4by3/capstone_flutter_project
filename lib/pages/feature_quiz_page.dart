import 'package:flutter/material.dart';

///quiz page that test users knowledge on specific facebook feature
///jaanane - for testing
///each feature has its own set of questions and tracks user's progress
class FeatureQuizPage extends StatefulWidget {
  ///index representing which feature's quiz to display
  ///0: Block, Restrict, Report Usage
  ///1: Facebook groups
  ///2: Audience Settings for Posts
  ///3: Interaction on Other's Posts
  ///4: Tag Review and Settings
  final int featureIndex;

  FeatureQuizPage({required this.featureIndex});

  @override
  _FeatureQuizPageState createState() => _FeatureQuizPageState();
}

class _FeatureQuizPageState extends State<FeatureQuizPage> {
  ///tracks the user's current score in the quiz
  int score = 0;

  ///Maps questions indices to the user's selected answers
  Map<int, String> selectedAnswers = {};

  ///indicates whether the quiz has been submitted
  bool isSubmitted = false;

  ///comprehensice question bank for all features
  ///organized by feature index containing questions, options and correct answers
  final Map<int, List<Map<String, dynamic>>> featureQuestions = {
    0: [
      // Block, Restrict, Report Usage Question
      {
        'question': "A user you don't know has sen you multiple inappropriate messages and it's making you uncomfortable. \n Do you: ",
        'options': [
          'A) Ignore the message',
          'B) Block the user so they cannot contact you again',
          'C) Respond to the message and ask them to stop',
          'D) Report the user for inappropriate behaviour'
        ],
        'answer': 'B) Block the user so they cannot contact you again'
      },
      {
        'question': 'You find a Facebook profile using your name and photos to impersonate you and send messages to people. \n Do you: ',
        'options': [
          'A) Ignore it assuming it will go away',
          'B) Send a message to the profile asking them to stop the impersonation',
          'C) Report the profile to Facebook for impersonation',
          'D) Post about it publicly to let the others know'
        ],
        'answer': 'C) Report the profile to Facebook for impersonation'
      },
      {
        'question':
            'A group of users leaves hurtful comments on your recent post, criticizing your opinions and spreading misinformation about you. \n Do you: ',
        'options': [
          'A) Delete your post and stay quiet',
          'B) Block the users posting hurtful comments',
          'C) Report the comments to Facebook for violating community guidelines',
          'D) Respond to the comments to defend yourself'
        ],
        'answer':
            'C) Report the comments to Facebook for violating community guidelines'
      },
      {
        'question': "A friend keeps posting comments on your personal photos that makes you uncomfortable, but you don't want to unfriend them because they are part of your social circle. \n Do you: ",
        'options': [
          'A) Restrict the friend so they can only see your public posts',
          'B) Remove them from your friend list',
          'C) Ask them privately to stop commenting on your photos',
          'D) Block the friend immediately'
        ],
        'answer': 'A) Restrict the friend so they can only see your public posts'
      },
      {
        'question':
            'You frequently receive friend request from strangers who immediately send spam messages or inappropriate content. \n Do you:',
        'options': [
          'A) Accept the request and ignore the messages',
          'B) Block the user immediately after receiving the requests',
          'C) Report the accounts for spamming',
          'D) Restrict your friend request setting to \'Friends of Friends\' to reduce unwanted requests'
        ],
        'answer': 'D) Restrict your friend request setting to \'Friends of Friends\' to reduce unwanted requests'
      },
    ],
    1: [
      // Facebook Groups Question
      {
        'question': 'Who can see the posts in a private Facebook group?',
        'options': [
          'A) Only group members',
          'B) Anyone on Facebook',
          'C) Only the group admin',
          'D) Friends of group members'
        ],
        'answer': 'A) Only group members'
      },
      {
        'question': 'What happens when you switch a Facebook group from private to public?',
        'options': [
          'A) Only new posts become public',
          'B) All past and future posts become visible to everyone',
          'C) Only admins can see old posts, but new posts are public',
          'D) Facebook does not allow switching a group from private to public'
        ],
        'answer': 'B) All past and future posts become visible to everyone'
      },
      {
        'question': 'If you leave a Facebook group, what happens to the posts you shared in the group?',
        'options': [
          'A) They get automatically deleted',
          'B) They remain in the group unless you delete them manually',
          'C) Only admins can see them',
          'D) They disappear after 30 days'
        ],
        'answer': 'B) They remain in the group unless you delete them manually'
      },
      {
        'question': 'Who can approve new members in a Facebook group?',
        'options': [
          'A) Only the group admin',
          'B) Group admins and moderators',
          'C) Any group member',
          'D) Only Facebook itself'
        ],
        'answer': 'B) Group admins and moderators'
      },
      {
        'question': 'What can group admins do to enhance privacy in a Facebook group?',
        'options': [
          'A) Turn off post approvals for all members',
          'B) Make all group posts visible to non-members',
          'C) Allow anyone to join',
          'D) Set the group to private and restrict who can join'
        ],
        'answer': 'D) Set the group to private and restrict who can join'
      },
    ],
    2: [
      // Audience Setting for Posts Question
      {
        'question': 'You post a photo from a family gathering on your profile. A colleague comments on the post, mentioning details about your workplace. \n How should you handle the audience settings for this post?',
        'options': [
          'A) Leave it public to let everyone enjoy the post',
          'B) Change the audience to \'Friends Only\'',
          'C) Use the custom audience option to exclude colleagues',
          'D) Delete the comment to avoid workplace-related exposure'
        ],
        'answer': 'C) Use the custom audience option to exclude colleagues'
      },
      {
        'question': 'You discover an old post from two years ago that is still set to \'Public\' The post includes a photo of your vacation with the location details. \n What is the best course of action?',
        'options': [
          'A) Leave it public as it\'s an old post ',
          'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\'',
          'C) Delete the post to eliminate any potential privacy risks',
          'D) Edit the post to remove location details while keeping it public'
        ],
        'answer': 'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\''
      },
      {
        'question': 'You share advice in a public professional group. Later, you noticed some group members visiting your profile and sending connection requests. \n How can you prevent this exposure?',
        'options': [
          'A) Leave the group to avoid further interactions',
          'B) Change your future post audience to  \'Friends\' or \'Only Me\'',
          'C) Ignore the requests and continue posting in the group',
          'D) Set profile details visible to \'Friends Only\' or \'Custom Audience\''
        ],
        'answer': 'D) Set profile details visible to \'Friends Only\' or \'Custom Audience\''
      },
      {
        'question': 'You announce your new job on your profile. You notice that acquaintances you don\'t interact with are congratulating you. \n What is the best way to control the audience for such updates?',
        'options': [
          'A) Keep the post public to let everyone celebrate with you',
          'B) Adjust the audience to include only close friends and family',
          'C) Use \'Custom Audience\' to exclude people you rarely interact with',
          'D) Delete the post to avoid unwanted attention'
        ],
        'answer': 'C) Use \'Custom Audience\' to exclude people you rarely interact with'
      },
      {
        'question': 'You create a post inviting friends to your birthday party. Later, you realize it\'s visible to your entire friend list, including colleagues and acquaintances. \n How can you fix the audience settings?',
        'options': [
          'A) Let it remain as it is; it\'s just a birthday invitation',
          'B) Change the audience to include only specific people invited to the party',
          'C) Delete the post and send individual invitations instead',
          'D) Edit the post and add a note clarifying it\'s for specific people'
        ],
        'answer': 'B) Change the audience to include only specific people invited to the party'
      },
    ],
    3: [
      // Interaction on Others' Posts Question
      {
        'question':
            'You comment on a public post shared by a news page. The post sparks a debate, and your comment receives several replies from strangers. Some of them visit your profile, and one even sends you a friend request. \n What action should you take to protect your privacy?',
        'options': [
          'A) Reply to all the comments to clarify your point',
          'B) Adjust your privacy settings to limit profile visibility to \'Friends Only\'',
          'C) Ignore the situation and keep engaging with strangers on the post',
          'D) Block anyone who interacts with your comment'
        ],
        'answer': 'B) Adjust your privacy settings to limit profile visibility to \'Friends Only\''
      },
      {
        'question': 'You share a public post from a community page, and someone from that page comments on your post. They mentioned they liked your content and suggest checking out their profile. \n How can you minimize exposure to stranger?',
        'options': [
          'A) Delete the shared post',
          'B) Check the privacy settings of your shared content and restrict it to \'Friends\'',
          'C) Ignore the comment and continue sharing public posts',
          'D) Engage with the stranger to learn more about them'
        ],
        'answer': 'B) Check the privacy settings of your shared content and restrict it to \'Friends\''
      },
      {
        'question': 'You like a photo shared publicly by a stranger in a travel group. Shortly after, you receive a direct message from them asking about your interest in travelling. \n WHat would be the safest response?',
        'options': [
          'A)  Review your group activity and limit your profile information visibility in your groups',
          'B) Respond politely and share your travel experiences',
          'C) Unfollow the group to avoid further interaction',
          'D) Ignore the message and continue liking similar posts'
        ],
        'answer': 'A)  Review your group activity and limit your profile information visibility in your groups'
      },
      {
        'question':
            'You are tagged by a friend in a public group post. The post is a funny meme, but it attracts comments and reactions from strangers/ \n What steps should you take?',
        'options': [
          'A) Leave the tag as it is; it\'s harmless',
          'B) Engage with the comments to maintain a fun discussion',
          'C) Adjust your tagging settings to require approval for future tags',
          'D) Remove the tag and ask your friend to seek permission before tagging'
        ],
        'answer': 'D) Remove the tag and ask your friend to seek permission before tagging'
      },
      {
        'question': 'You post a question in a public hobby group. A stranger replies with an answer but also starts following your profile. \n What should you do to protect your privacy?',
        'options': [
          'A) Thank the stranger and accept the follower',
          'B) Message the stranger to confirm their intention',
          'C) Review your profile visibility settings and restrict it to \'Friends Only\'',
          'D) Remove the post to stop further exposure'
        ],
        'answer': 'C) Review your profile visibility settings and restrict it to \'Friends Only\''
      },
    ],
    4: [
      // Tag and Review Settings Question
      {
        'question': 'You go to a very fun party, and your friend posts you in a picture without asking you if it is all right. The post comes up as public which means most of your Facebook friends can see the picture. \n What do you do to keep your privacy but still feel okay with what happened? ',
        'options': [
          'A) Ignore the posting completely; it\'s just a tag, and no harm caused',
          'B) Politely tell your friend to remove the tag or bring down the photo completely',
          'C) Under the \'Review Tags\' feature on Facebook you can determine whether the tag will show up on your profile' ,
          'D) Edit the tagged posts audience to one that only shows the post to specific people'
        ],
        'answer': 'C) Under the \'Review Tags\' feature on Facebook you can determine whether the tag will show up on your profile'
      },
      {
        'question': 'Facebook also has a feature known as \'Review Tags\'. This setting provides the user with even further control based on the different content that has been placed on their profiles. Whic of the following statements best describes what the \'Review Tags\' feature does for you?',
        'options': [
          'A) Automatically delete all tags from your photos and post without notifying the person who tagged you',
          'B) Approve and reject tags added by others before they are displayed on your profile or timeline',
          'C) Send a notification to anyone who tags you, reminding them to seek you',
          'D) Permanently block tagging on your profile to avoid such situations in the future'
        ],
        'answer': 'B) Approve and reject tags added by others before they are displayed on your profile or timeline'
      },
      {
        'question': 'Suppose a friend has tagged you in a group photo taken at some event. The friend created the posting with the audience setting of \'Friends\'. According to Facebook audience settings, who would have access to this tagged posting?',
        'options': [
          'A) Your tagged post is only accessible by you Facebook friends regardless of the settings set by your friend',
          'B) It\'s on your friend\'s profile; only their Facebook friends can view it',
          'C) Due to the tag, anyone on Facebook will be able to see the post, regardless of whether they\'re in your friend\'s network of connections',
          'D) Your friends, your friends\'s friends, and any others that your friend defines when setting the custom audience for it will be able to see the post'
        ],
        'answer': 'D) Your friends, your friends\'s friends, and any others that your friend defines when setting the custom audience for it will be able to see the post'
      },
      {
        'question': 'You get tagged in a post that contains any kind of sensitive personal information, which is likely to include your location or an embarrassing photo. You don\'t want this being widely visbile or hurting anyone. What can you do to protect yourself from such situation?',
        'options': [
          'A) Untag yourself from the photo or posting with the untagging option on the post itself',
          'B) Report the post on Facebook and identify the violation of Community Guidelines or Terms of Service',
          'C) Change your privacy settings to tagged content only showing to a limited audience',
          'D) Take all the above measure for complete protection of your privacy'
        ],
        'answer': 'D) Take all the above measure for complete protection of your privacy'
      },
      {
        'question': 'If you wish to stay updated and get notified every time anyone tags you in any post or photo, then to turn this on and monitor your tags, what would you do?',
        'options': [
          'A) You enable the notifications of tagging in the privacy and notification settings of your account',
          'B) Click directly under the post your\'re tagged in and enable \'Turn on notification\'',
          'C) Undergo the settings on your account using Facebook\'s \'Privacy Checkup\' tool; including tagging notifications and approvals',
          'D) There is no setting for notifications of tags since all users receive them by default from Facebook'
        ],
        'answer': 'A) You enable the notifications of tagging in the privacy and notification settings of your account'
      },
    ],
  };

  ///COnverts the feature index to a human readable feature name
  ///returns the name of the feature being tested
  String getFeatureName() {
    switch (widget.featureIndex) {
      case 0:
        return 'Block, Restrict, Report Usage';
      case 1:
        return 'Facebook Groups';
      case 2:
        return 'Audience Setting for Posts';
      case 3:
        return 'Interaction on Others\' Posts';
      case 4:
        return 'Tag Review and Settings';
      default:
        return 'Unknown Feature';
    }
  }

  ///calculates the final score and displays the results dialog
  ///- compares selected answer with the correct answer
  ///- updates the score state
  ///- shows a completion dialog with the score and options to review or return
  void _submitQuiz() {
    int newScore = 0;
    selectedAnswers.forEach((index, answer) {
      final correctAnswer =
          featureQuestions[widget.featureIndex]![index]['answer'];
      if (answer == correctAnswer) newScore++;
    });

    setState(() {
      score = newScore;
      isSubmitted = true;
    });
    //show completion dialog with score and option
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Column(
            children: [
              Icon(
                score == 5 ? Icons.stars : Icons.school,
                color: score == 5 ? Colors.amber : Colors.deepPurpleAccent,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                score == 5 ? 'Congratulations!' : 'Quiz Complete',
                style: const TextStyle(color: Colors.deepPurple),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You scored $score out of 5',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                score == 5
                    ? 'Perfect score! You\'ve mastered this feature!'
                    : 'Keep practicing to improve your score!',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Review Answers'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
                child: const Text(
                'Return to Home',
                style: TextStyle(color: Colors.black),
                ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, score);
              },
            ),
          ],
        );
      },
    );
  }

  void _resetQuiz() {
    setState(() {
      score = 0;
      selectedAnswers.clear();
      isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = featureQuestions[widget.featureIndex] ?? [];
    final questionsAnswered = selectedAnswers.length;
    final totalQuestions = questions.length;

    //saves submission on back button
    return PopScope(
      canPop: !isSubmitted,
      onPopInvoked: (didPop) {
        if (!didPop && !isSubmitted) {
          Navigator.pop(context);
        } else if (!didPop && isSubmitted) {
          Navigator.pop(context, score);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getFeatureName(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.deepPurpleAccent,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurpleAccent.withOpacity(0.3), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          '$questionsAnswered/$totalQuestions',
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: questionsAnswered / totalQuestions,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation(Colors.deepPurpleAccent),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    // final isAnswered = selectedAnswers.containsKey(index);
                    final isCorrect = isSubmitted &&
                        selectedAnswers[index] == question['answer'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Q${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    question['question'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isSubmitted)
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ...question['options'].map<Widget>((option) {
                              final isSelected =
                                  selectedAnswers[index] == option;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.deepPurpleAccent
                                        : Colors.grey[300]!,
                                  ),
                                  color: isSelected
                                      ? Colors.deepPurpleAccent.withOpacity(0.1)
                                      : Colors.white,
                                ),
                                child: RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue: selectedAnswers[index],
                                  onChanged: isSubmitted
                                      ? null
                                      : (value) {
                                          setState(() {
                                            selectedAnswers[index] = value!;
                                          });
                                        },
                                  activeColor: Colors.deepPurpleAccent,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (!isSubmitted)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: questionsAnswered == totalQuestions
                        ? _submitQuiz
                        : null,
                    child: const Text(
                      'Submit Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
              if (isSubmitted) // Show Redo Quiz button after submission
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                    onPressed: _resetQuiz, // Call reset function
                    child: const Text(
                      'Redo Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
