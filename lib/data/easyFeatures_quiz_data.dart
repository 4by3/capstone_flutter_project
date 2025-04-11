

// !!!! facebook groups section looks pretty incomplete

/// Comprehensive question bank for easy features
/// Organized by feature index containing questions, options, and correct answers
final Map<int, List<Map<String, dynamic>>> easyFeatureQuestions = {
  0: [
    /// Block, Restrict, Report Usage Questions
    {
      'scenarioNumber': 1,
      'scenario': 'A user you don’t know has sent you multiple inappropriate messages.',
      'question': 'What should you do?',
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
      'scenarioNumber': 2,
      'scenario': 'You find a Facebook profile impersonating you.',
      'question': 'What should you do?',
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
      'scenarioNumber': 3,
      'scenario': 'A group of users leaves hurtful comments on your recent post, criticizing your opinions and spreading misinformation about you.',
      'question': 'Do you:',
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
      'scenarioNumber': 4,
      'scenario': 'A friend keeps posting comments on your personal photos that makes you uncomfortable, but you don’t want to unfriend them because they are part of your social circle.',
      'question': 'Do you:',
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
      'scenarioNumber': 5,
      'scenario': 'You frequently receive friend requests from strangers who immediately send spam messages or inappropriate content.',
      'question': 'What should you do?',
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
    /// Facebook Groups Questions
    {
      'scenario': '',
      'question': 'Who can see the posts in a private Facebook group?',
      'options': [
        'A) Only group members',
        'B) Anyone on Facebook',
        'C) Only the group admin',
        'D) Friends of group members'
      ],
      'answer': 'A) Only group members',
      'feedback': 'test1'
    },
    {
      'scenario': '',
      'question': 'What happens when you switch a Facebook group from private to public?',
      'options': [
        'A) Only new posts become public',
        'B) All past and future posts become visible to everyone',
        'C) Only admins can see old posts, but new posts are public',
        'D) Facebook does not allow switching a group from private to public'
      ],
      'answer': 'B) All past and future posts become visible to everyone',
      'feedback': 'test2'
    },
    {
      'scenario': '',
      'question': 'If you leave a Facebook group, what happens to the posts you shared in the group?',
      'options': [
        'A) They get automatically deleted',
        'B) They remain in the group unless you delete them manually',
        'C) Only admins can see them',
        'D) They disappear after 30 days'
      ],
      'answer': 'B) They remain in the group unless you delete them manually',
      'feedback': 'test3'
    },
    {
      'scenario': '',
      'question': 'Who can approve new members in a Facebook group?',
      'options': [
        'A) Only the group admin',
        'B) Group admins and moderators',
        'C) Any group member',
        'D) Only Facebook itself'
      ],
      'answer': 'B) Group admins and moderators',
      'feedback': 'test4'
    },
    {
      'scenario': '',
      'question': 'What can group admins do to enhance privacy in a Facebook group?',
      'options': [
        'A) Turn off post approvals for all members',
        'B) Make all group posts visible to non-members',
        'C) Allow anyone to join',
        'D) Set the group to private and restrict who can join'
      ],
      'answer': 'D) Set the group to private and restrict who can join',
      'feedback': 'test5'
    },
  ],
  2: [
    /// Audience Setting for Posts Questions
    {
      'scenarioNumber': 1,
      'scenario': 'You post a photo from a family gathering on your profile. A colleague comments on the post, mentioning details about your workplace.',
      'question': 'How should you handle the audience settings for this post?',
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
      'scenarioNumber': 2,
      'scenario': 'You discover an old post from two years ago that is still set to \'Public\'. The post includes a photo of your vacation with the location details.',
      'question': 'What is the best course of action?',
      'options': [
        'A) Leave it public as it’s an old post ',
        'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\'',
        'C) Delete the post to eliminate any potential privacy risks',
        'D) Edit the post to remove location details while keeping it public'
      ],
      'answer': 'B) Use the \'Limit Past Posts\' feature to change the audience to \'Friends Only\'',
      'feedback': 'test2'
    },
    {
      'scenarioNumber': 3,
      'scenario': 'You share advice in a public professional group. Later, you noticed some group members visiting your profile and sending connection requests.',
      'question': 'How can you prevent this exposure?',
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
      'scenarioNumber': 4,
      'scenario': 'You announce your new job on your profile. You notice that acquaintances you don’t interact with are congratulating you.',
      'question': 'What is the best way to control the audience for such updates?',
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
      'scenarioNumber': 5,
      'scenario': 'You create a post inviting friends to your birthday party. Later, you realize it’s visible to your entire friend list, including colleagues and acquaintances.',
      'question': 'How can you fix the audience settings?',
      'options': [
        'A) Let it remain as it is; it’s just a birthday invitation',
        'B) Change the audience to include only specific people invited to the party',
        'C) Delete the post and send individual invitations instead',
        'D) Edit the post and add a note clarifying it’s for specific people'
      ],
      'answer': 'B) Change the audience to include only specific people invited to the party',
      'feedback': 'test5'
    },
  ],
  3: [
    /// Interaction on Others' Posts Questions
    {
      'scenarioNumber': 1,
      'scenario': 'You comment on a public post shared by a news page. The post sparks a debate, and your comment receives several replies from strangers. Some of them visit your profile, and one even sends you a friend request.',
      'question': 'What action should you take to protect your privacy?',
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
      'scenarioNumber': 2,
      'scenario': 'You share a public post from a community page, and someone from that page comments on your post. They mentioned they liked your content and suggest checking out their profile.',
      'question': 'How can you minimize exposure to stranger?',
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
      'scenarioNumber': 3,
      'scenario': 'You like a photo shared publicly by a stranger in a travel group. Shortly after, you receive a direct message from them asking about your interest in travelling.',
      'question': 'What would be the safest response?',
      'options': [
        'A) Review your group activity and limit your profile information visibility in your groups',
        'B) Respond politely and share your travel experiences',
        'C) Unfollow the group to avoid further interaction',
        'D) Ignore the message and continue liking similar posts'
      ],
      'answer': 'A) Review your group activity and limit your profile information visibility in your groups',
      'feedback': 'test3'
    },
    {
      'scenarioNumber': 4,
      'scenario': 'You are tagged by a friend in a public group post. The post is a funny meme, but it attracts comments and reactions from strangers.',
      'question': 'What steps should you take?',
      'options': [
        'A) Leave the tag as it is; it’s harmless',
        'B) Engage with the comments to maintain a fun discussion',
        'C) Adjust your tagging settings to require approval for future tags',
        'D) Remove the tag and ask your friend to seek permission before tagging'
      ],
      'answer': 'D) Remove the tag and ask your friend to seek permission before tagging',
      'feedback': 'test4'
    },
    {
      'scenarioNumber': 5,
      'scenario': 'You post a question in a public hobby group. A stranger replies with an answer but also starts following your profile.',
      'question': 'What should you do to protect your privacy?',
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
    /// Tag and Review Settings Questions
    {
      'scenarioNumber': 1,
      'scenario': 'Your friend tags you in an unflattering photo.',
      'question': 'Which feature lets you review this before it appears on your timeline?',
      'options': [
        'A) Tag review',
        'B) Privacy checkup',
        'C) News feed preferences',
        'D) Profile lock'
      ],
      'answer': 'A) Tag review',
      'feedback': 'Tag review lets you ses and approve photos before they appear on your timeline.'
    },
    {
      'scenarioNumber': 2,
      'scenario': 'Someone tags you in a post and you have tag review turned on.',
      'question': 'What happens next?',
      'options': [
        'A) The tag shows up on your timeline right away',
        'B) Facebook removes the tag after 24 hours',
        'C) You receive a notification and can approve or ignore the tag',
        'D) The post is automatically hidden from everyone'
      ],
      'answer': 'C) You receive a notification and can approve or ignore the tag',
      'feedback': 'You will receive a notification, and the tag won\'t show up unless you approve it.'
    },
    {
      'scenario': '',
      'question': 'What does Facebook’s review feature do for you?',
      'options': [
        'A) Automatically tags your friends',
        'B) Hides all tag from profile',
        'C) Organize photo album',
        'D) Review post before they show on your timeline'
      ],
      'answer': 'D) Review post before they show on your timeline',
      'feedback': 'Tag review helps you approve or deny tags before they appear on your profile.'
    },
    {
      'scenario': '',
      'question': 'Why might someone want to turn on tag review?',
      'options': [
        'A) To increase number of likes on their posts',
        'B) To block all friends from seeing their profile',
        'C) To have control over what appears on their timeline',
        'D) To automatically tag all their friends in photos'
      ],
      'answer': 'C) To have control over what appears on their timeline',
      'feedback': 'Tag review helps you control your Facebook presence by letting you decide which tagged post appear on your profile.'
    },
    {
      'scenario': '',
      'question': 'Can you still be tagged in a post if you have tag review turned on?',
      'options': [
        'A) No all tags are blocked',
        'B) Yes, but you can review it before it shows on your timeline',
        'C) Only by close friends',
        'D) Only in photos, not in text posts'
      ],
      'answer': 'B) Yes, but you can review it before it shows on your timeline',
      'feedback': 'Tag review doesn\'t stops tag, it lets you decide wheter to show them on your timeline.'
    },
  ],
};