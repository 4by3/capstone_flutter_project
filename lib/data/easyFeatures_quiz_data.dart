

/// Comprehensive question bank for easy features
/// Organized by feature index containing questions, options, and correct answers
final Map<int, List<Map<String, dynamic>>> easyFeatureQuestions = {
  0: [
    /// Block, Restrict, Report Usage Questions
    {
      'scenarioNumber': 1,
      'scenario': 'Ayesha uses Facebook to keep in touch with friends, family, and coworkers. Recently, she received unwanted messages from a stranger. One friend keeps reacting strangely to her posts, and she also discovers someone using her name and photo on a fake account.',
      'question': 'Ayesha gets spam messages from a stranger. What should she do to stop them?',
      'options': [
        'A) Reply and ask who they are',
        'B) Block the user',
        'C) Ignore the messages',
        'D) Send a message back'
      ],
      'answer': 'B) Block the user',
      'feedback': 'Blocking someone stops all contact—messages, tags, and profile views.'
    },
    {
      //cluster 1: Safer Experience on Facebook
      'scenario': '',
      'question': ' What happens when Ayesha blocks someone?',
      'options': [
        'A) They can still comment on public posts',
        'B) They can still search her name',
        'C) They can’t see or interact with her',
        'D) They get a message saying they were blocked'
      ],
      'answer': 'C) They can’t see or interact with her',
      'feedback': 'Blocked users can\'t see your profile or posts or interact with you on Facebook.'
    },
    {
      'scenario': '',
      'question': 'Ayesha finds a fake Facebook profile using her name and photo. What should she do?',
      'options': [
        'A) Block the fake account',
        'B) Report the fake account to Facebook',
        'C) Post about it on her timeline',
        'D) Message the account and ask them to stop'
      ],
      'answer': 'B) Report the fake account to Facebook',
      'feedback': 'Reporting fake profiles helps Facebook investigate and remove impersonation.'
    },
    {
      //Cluster 2: Quietly Controlling What Others See
      'scenario': '',
      'question': 'Ayesha doesn\’t want one friend to see her posts but still wants to stay friends. What should she use?',
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
      'scenario': '',
      'question': 'What can a restricted friend see on Ayesha’s profile?',
      'options': [
        'A) All posts',
        'B) Only stories',
        'C) Public posts only',
        'D) Nothing at all'
      ],
      'answer': 'C) Public posts only',
      'feedback': 'Restricted friends won’t know they’re restricted and can only view public posts.'
    },
  ],
  1: [
    /// Facebook Groups Questions
    {
      'scenarioNumber': 1,
      'scenario': 'Amira joins a Facebook group called “Home Gardening Tips.” The group is full of helpful posts, and she enjoys learning from others. As she becomes more active, she starts noticing how group rules and admins help keep the group organized and respectful.',
      'question': 'Amira wants to share a photo of her new plants. What should she check before posting? ',
      'options': [
        'A) If the group allows photo posts',
        'B) Her internet connection',
        'C) How many likes others got',
        'D) Her friend’s opinion'
      ],
      'answer': 'A) If the group allows photo posts',
      'feedback': 'Always check the group rules to make sure your post follows what’s allowed. '
    },
    {
      //cluster 1: admin role and group rules
      'scenario': '',
      'question': 'Someone in the gardening group posts an unrelated ad. What can the group admin do?',
      'options': [
        'A) Like the post',
        'B) Ignore it',
        'C) Remove the post and explain the rule',
        'D) Comment with a warning emoji'
      ],
      'answer': 'C) Remove the post and explain the rule',
      'feedback': 'Admins can remove off-topic content and remind members of the group rules'
    },
    {
      'scenario': '',
      'question': 'Amira wants to avoid posting the wrong kind of content again. What should she do?',
      'options': [
        'A) Ask the admin before posting',
        'B) Post and hope for the best',
        'C) Delete all her old posts',
        'D) Comment instead of posting'
      ],
      'answer': 'A) Ask the admin before posting',
      'feedback': 'If unsure, asking the admin is a great way to stay safe and respectful.'
    },
    {
      //cluster 2: group privacy and safety
      'scenario': '',
      'question': 'Amira wants to join a private group about indoor plants. What does "private" mean? ',
      'options': [
        'A) Anyone can see posts',
        'B) Only members can see the posts',
        'C) The group has no rules',
        'D) Only admins can post'
      ],
      'answer': 'B) Only members can see the posts',
      'feedback': 'Private groups limit visibility, only members can see posts and discussions.'
    },
    {
      'scenario': '',
      'question': 'What happens if a public group is changed to private?',
      'options': [
        'A) Old posts disappear',
        'B) All posts stay public',
        'C) Only new posts are private',
        'D) Old and new posts become visible only to members'
      ],
      'answer': 'D) Old and new posts become visible only to members',
      'feedback': 'When a group becomes private, all past and future content becomes visible only to members.'
    },
  ],
  2: [
    /// Audience Setting for Posts Questions
    {
      'scenarioNumber': 1,
      'scenario': 'David often shares updates on Facebook—photos, work news, and personal thoughts. He wants to make sure the right people see the right posts. For example, he wants to share his new job with coworkers, a birthday memory with close friends, and a private journal entry just for himself.',
      'question': ' David wants to share a post only with people on his friend list. Which setting should he use?',
      'options': [
        'A) Public',
        'B) Friends',
        'C) Only Me',
        'D) Custom'
      ],
      'answer': 'B) Friends',
      'feedback': 'The "Friends" setting makes your post visible only to people you\'ve added as friends.'
    },
    {
      //cluster 1: choosing who sees your post
      'scenario': '',
      'question': 'David wants to hide a post from a few specific people. What setting should he use?',
      'options': [
        'A) Friends ',
        'B) Friends Except…',
        'C) Public',
        'D) Only Me'
      ],
      'answer': 'B) Friends Except…',
      'feedback': '"Friends Except…" lets you stay connected but hide the post from selected people. '
    },
    {
      'scenario': '',
      'question': 'David wants to share a post with just his team at work. What setting helps him do that? ',
      'options': [
        'A) Close Friends',
        'B) Custom',
        'C) Public',
        'D) Friends'
      ],
      'answer': 'B) Custom',
      'feedback': 'The "Custom" setting allows you to choose exactly who can or can\'t see your post. '
    },
    {
      //cluster 2: keeping your post private
      'scenario': '',
      'question': 'David writes a personal journal post that he doesn’t want anyone else to see. What setting should he use?',
      'options': [
        'A) Public',
        'B) Friends',
        'C) Friends Except…',
        'D) Only Me'
      ],
      'answer': 'D) Only Me',
      'feedback': '"Only Me" hides the post from everyone else, it’s fully private.'
    },
    {
      'scenario': '',
      'question': 'David shared a post with “Friends,” but now wants to make it completely private. What should he do?',
      'options': [
        'A) Delete the post',
        'B) Turn off comments',
        'C) Change the audience to “Only Me”',
        'D) Tag fewer people'
      ],
      'answer': 'C) Change the audience to “Only Me”',
      'feedback': 'You can update the audience on any of your posts at any time—even after posting.'
    },
  ],
  3: [
    /// Interaction on Others' Posts Questions
    {
      'scenarioNumber': 1,
      'scenario': 'Nila was scrolling through Facebook when she saw a post from her friend Rehan celebrating his graduation. She liked the post, left a comment saying "Congrats!", and later replied to another friend’s comment on the same post. The next day, Rehan changed the post\'s privacy settings from "Public" to "Friends Only." ',
      'question': 'What did Nila do when she liked and commented on Rehan\’s post? ',
      'options': [
        'A) Ignored the post',
        'B) Interacted with the post',
        'C) Changed the privacy',
        'D) Blocked Rehan'
      ],
      'answer': 'B) Interacted with the post',
      'feedback': 'Liking, commenting, or replying to a post are all forms of interaction. '
    },
    {
      //cluster 1: when privacy settings change
      'scenario': '',
      'question': 'Rehan\'s post was set to “Public.” Who could see Nila’s comment on it? ',
      'options': [
        'A) Only Rehan',
        'B) Only Nila\'s friends',
        'C) Anyone on Facebook',
        'D) Only mutual friends'
      ],
      'answer': 'C) Anyone on Facebook',
      'feedback': 'Public posts are visible to everyone, including all comments and reactions.'
    },
    {
      'scenario': '',
      'question': 'Who controls who can see Nila’s comment on Rehan\’s post?',
      'options': [
        'A) Only Nila',
        'B) Only Rehan',
        'C) Nila’s friends',
        'D) Everyone who reacted to the post'
      ],
      'answer': 'B) Only Rehan',
      'feedback': ' Rehan controls who can see the post and its comments, but Nila still owns her comment and can delete or edit it anytime. '
    },
    {
      //cluster 2: interacting respectfully
      'scenario': '',
      'question': 'Nila sees a post about someone going through a hard time. What is the most thoughtful way to respond? ',
      'options': [
        'A) Use the “Haha” reaction',
        'B) Leave a kind comment',
        'C) Scroll past',
        'D) React with “Wow”'
      ],
      'answer': 'B) Leave a kind comment',
      'feedback': 'Leaving a supportive comment shows empathy and kindness.'
    },
    {
      'scenario': '' ,
      'question': 'Why is it important to be careful when reacting to serious posts?',
      'options': [
        'A) Facebook might ban your account',
        'B) Reactions affect the post’s privacy',
        'C) People may misunderstand your intention',
        'D) Your reaction becomes private'
      ],
      'answer': 'C) People may misunderstand your intention',
      'feedback': 'Using the wrong reaction on a serious post may hurt others, even if you didn’t mean to. '
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