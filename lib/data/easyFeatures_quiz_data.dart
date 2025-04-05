  ///comprehensice question bank for easy features
  ///organized by feature index containing questions, options and correct answers
  final Map<int, List<Map<String, dynamic>>> easyFeatureQuestions = {
    0: [
      /// Block, Restrict, Report Usage Question
      {
        'question': "A user you don't know has sent you multiple inappropriate messages. What should you do?",
        'options': [
          'A) Ignore the message',
          'B) Block the user',
          'C) Respond and ask them to stop',
          'D) Report the user'
        ],
        'answer': 'B) Block the user',
        'feedback': 'test1'
      },
      {
        'question': 'You find a Facebook profile impersonating you. What should you do?',
        'options': [
          'A) Ignore it',
          'B) Send a message asking them to stop',
          'C) Report the profile',
          'D) Post about it publicly'
        ],
        'answer': 'C) Report the profile',
        'feedback': 'test2'
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
        'answer': 'C) Report the comments to Facebook for violating community guidelines',
        'feedback': 'test3'
      },
      {
        'question': "A friend keeps posting comments on your personal photos that makes you uncomfortable, but you don't want to unfriend them because they are part of your social circle. \n Do you: ",
        'options': [
          'A) Restrict the friend so they can only see your public posts',
          'B) Remove them from your friend list',
          'C) Ask them privately to stop commenting on your photos',
          'D) Block the friend immediately'
        ],
        'answer': 'A) Restrict the friend so they can only see your public posts',
        'feedback': 'test4'
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
        'answer': 'D) Restrict your friend request setting to \'Friends of Friends\' to reduce unwanted requests',
        'feedback': 'test5'
      },
    ],
    1: [
      // Facebook Groups Question
      {
        "question": "Who can see the posts in a private Facebook group?",
        "options": [
          "A) Only group members",
          "B) Anyone on Facebook",
          "C) Only the group admin",
          "D) Friends of group members"
        ],
        "answer": "A) Only group members",
        "feedback": "test1"
      },
      {
        "question": "What happens when you switch a Facebook group from private to public?",
        "options": [
          "A) Only new posts become public",
          "B) All past and future posts become visible to everyone",
          "C) Only admins can see old posts, but new posts are public",
          "D) Facebook does not allow switching a group from private to public"
        ],
        "answer": "B) All past and future posts become visible to everyone",
        "feedback": "test2"
      },
      {
        "question": "If you leave a Facebook group, what happens to the posts you shared in the group?",
        "options": [
          "A) They get automatically deleted",
          "B) They remain in the group unless you delete them manually",
          "C) Only admins can see them",
          "D) They disappear after 30 days"
        ],
        "answer": "B) They remain in the group unless you delete them manually",
        "feedback": "test3"
      },
      {
        "question": "Who can approve new members in a Facebook group?",
        "options": [
          "A) Only the group admin",
          "B) Group admins and moderators",
          "C) Any group member",
          "D) Only Facebook itself"
        ],
        "answer": "B) Group admins and moderators",
        "feedback": "test4"
      },
      {
        "question": "What can group admins do to enhance privacy in a Facebook group?",
        "options": [
          "A) Turn off post approvals for all members",
          "B) Make all group posts visible to non-members",
          "C) Allow anyone to join",
          "D) Set the group to private and restrict who can join"
        ],
        "answer": "D) Set the group to private and restrict who can join",
        "feedback": "test5"
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
        'answer': 'C) Use the custom audience option to exclude colleagues',
        'feedback': 'test1'
      },
      {
        'question': 'You discover an old post from two years ago that is still set to \'Public\' The post includes a photo of your vacation with the location details. \n What is the best course of action?',
        'options': [
          'A) Leave it public as it\'s an old post ',
          'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\'',
          'C) Delete the post to eliminate any potential privacy risks',
          'D) Edit the post to remove location details while keeping it public'
        ],
        'answer': 'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\'',
        'feedback': 'test2'
      },
      {
        'question': 'You share advice in a public professional group. Later, you noticed some group members visiting your profile and sending connection requests. \n How can you prevent this exposure?',
        'options': [
          'A) Leave the group to avoid further interactions',
          'B) Change your future post audience to  \'Friends\' or \'Only Me\'',
          'C) Ignore the requests and continue posting in the group',
          'D) Set profile details visible to \'Friends Only\' or \'Custom Audience\''
        ],
        'answer': 'D) Set profile details visible to \'Friends Only\' or \'Custom Audience\'',
        'feedback': 'test3'
      },
      {
        'question': 'You announce your new job on your profile. You notice that acquaintances you don\'t interact with are congratulating you. \n What is the best way to control the audience for such updates?',
        'options': [
          'A) Keep the post public to let everyone celebrate with you',
          'B) Adjust the audience to include only close friends and family',
          'C) Use \'Custom Audience\' to exclude people you rarely interact with',
          'D) Delete the post to avoid unwanted attention'
        ],
        'answer': 'C) Use \'Custom Audience\' to exclude people you rarely interact with',
        'feedback': 'test4'
      },
      {
        'question': 'You create a post inviting friends to your birthday party. Later, you realize it\'s visible to your entire friend list, including colleagues and acquaintances. \n How can you fix the audience settings?',
        'options': [
          'A) Let it remain as it is; it\'s just a birthday invitation',
          'B) Change the audience to include only specific people invited to the party',
          'C) Delete the post and send individual invitations instead',
          'D) Edit the post and add a note clarifying it\'s for specific people'
        ],
        'answer': 'B) Change the audience to include only specific people invited to the party',
        'feedback': 'test5'
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
        'answer': 'B) Adjust your privacy settings to limit profile visibility to \'Friends Only\'',
        'feedback': 'test1'
      },
      {
        'question': 'You share a public post from a community page, and someone from that page comments on your post. They mentioned they liked your content and suggest checking out their profile. \n How can you minimize exposure to stranger?',
        'options': [
          'A) Delete the shared post',
          'B) Check the privacy settings of your shared content and restrict it to \'Friends\'',
          'C) Ignore the comment and continue sharing public posts',
          'D) Engage with the stranger to learn more about them'
        ],
        'answer': 'B) Check the privacy settings of your shared content and restrict it to \'Friends\'',
        'feedback': 'test2'
      },
      {
        'question': 'You like a photo shared publicly by a stranger in a travel group. Shortly after, you receive a direct message from them asking about your interest in travelling. \n WHat would be the safest response?',
        'options': [
          'A)  Review your group activity and limit your profile information visibility in your groups',
          'B) Respond politely and share your travel experiences',
          'C) Unfollow the group to avoid further interaction',
          'D) Ignore the message and continue liking similar posts'
        ],
        'answer': 'A)  Review your group activity and limit your profile information visibility in your groups',
        'feedback': 'test3'
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
        'answer': 'D) Remove the tag and ask your friend to seek permission before tagging',
        'feedback': 'test4'
      },
      {
        'question': 'You post a question in a public hobby group. A stranger replies with an answer but also starts following your profile. \n What should you do to protect your privacy?',
        'options': [
          'A) Thank the stranger and accept the follower',
          'B) Message the stranger to confirm their intention',
          'C) Review your profile visibility settings and restrict it to \'Friends Only\'',
          'D) Remove the post to stop further exposure'
        ],
        'answer': 'C) Review your profile visibility settings and restrict it to \'Friends Only\'',
        'feedback': 'test5'
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
        'answer': 'C) Under the \'Review Tags\' feature on Facebook you can determine whether the tag will show up on your profile',
        'feedback': 'test1'
      },
      {
        'question': 'Facebook also has a feature known as \'Review Tags\'. This setting provides the user with even further control based on the different content that has been placed on their profiles. Whic of the following statements best describes what the \'Review Tags\' feature does for you?',
        'options': [
          'A) Automatically delete all tags from your photos and post without notifying the person who tagged you',
          'B) Approve and reject tags added by others before they are displayed on your profile or timeline',
          'C) Send a notification to anyone who tags you, reminding them to seek you',
          'D) Permanently block tagging on your profile to avoid such situations in the future'
        ],
        'answer': 'B) Approve and reject tags added by others before they are displayed on your profile or timeline',
        'feedback': 'test2'
      },
      {
        'question': 'Suppose a friend has tagged you in a group photo taken at some event. The friend created the posting with the audience setting of \'Friends\'. According to Facebook audience settings, who would have access to this tagged posting?',
        'options': [
          'A) Your tagged post is only accessible by you Facebook friends regardless of the settings set by your friend',
          'B) It\'s on your friend\'s profile; only their Facebook friends can view it',
          'C) Due to the tag, anyone on Facebook will be able to see the post, regardless of whether they\'re in your friend\'s network of connections',
          'D) Your friends, your friends\'s friends, and any others that your friend defines when setting the custom audience for it will be able to see the post'
        ],
        'answer': 'D) Your friends, your friends\'s friends, and any others that your friend defines when setting the custom audience for it will be able to see the post',
        'feedback': 'test3'
      },
      {
        'question': 'You get tagged in a post that contains any kind of sensitive personal information, which is likely to include your location or an embarrassing photo. You don\'t want this being widely visbile or hurting anyone. What can you do to protect yourself from such situation?',
        'options': [
          'A) Untag yourself from the photo or posting with the untagging option on the post itself',
          'B) Report the post on Facebook and identify the violation of Community Guidelines or Terms of Service',
          'C) Change your privacy settings to tagged content only showing to a limited audience',
          'D) Take all the above measure for complete protection of your privacy'
        ],
        'answer': 'D) Take all the above measure for complete protection of your privacy',
        'feedback': 'test4'
      },
      {
        'question': 'If you wish to stay updated and get notified every time anyone tags you in any post or photo, then to turn this on and monitor your tags, what would you do?',
        'options': [
          'A) You enable the notifications of tagging in the privacy and notification settings of your account',
          'B) Click directly under the post your\'re tagged in and enable \'Turn on notification\'',
          'C) Undergo the settings on your account using Facebook\'s \'Privacy Checkup\' tool; including tagging notifications and approvals',
          'D) There is no setting for notifications of tags since all users receive them by default from Facebook'
        ],
        'answer': 'A) You enable the notifications of tagging in the privacy and notification settings of your account',
        'feedback': 'test5'
      },
    ],
  };