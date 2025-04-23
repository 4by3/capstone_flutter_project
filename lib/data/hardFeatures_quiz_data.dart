final Map<int, List<Map<String, dynamic>>> hardFeatureQuestions = {
  0: [
    /// Block, Restrict, Report Usage Question
    {
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
      //cluster 1: advanced privacy management
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
      //cluster 2: security and account protection
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
      'scenarioNumber': 4,
      'scenario':
          'A friend’s account is tagging people in crypto posts.',
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
    // Facebook Groups Question
    {
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
      //cluster 1: group administration
      'scenarioNumber': 1,
      'scenario':
          'Your photography group has 5,000 members.',
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
      //cluster 2: Advanced group security
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
    // Audience Setting for Posts Question
    {
      //level 1: shared secrets
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
      'answer': 'B) Friends Except…',
      'feedback':
          '“Friends Except…” lets you hide your post from selected people without them knowing. '
    },
    {
      'scenario':
          '',
      'question':
          'You shared your job promotion using “Custom” to target a specific list. A tagged friend shares it. Who can now see the post?',
      'options': [
        'A) Everyone',
        'B) Only the original custom audience',
        'C) Only mutual friends',
        'D) Everyone except those tagged'
      ],
      'answer': 'B) Only the original custom audience',
      'feedback': 'Custom settings still control visibility, even when someone shares your post.'
    },
    {
      //cluster 1; advanced privacy management
      'scenario':
          '',
      'question': 'You want to hide a post from your boss and a few family members without unfriending them. What’s the best option? ',
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
      'scenario': '',
      'question':
          ' You change a post’s audience from Public to Friends. Who can no longer see it? ',
      'options': [
        'A) Everyone',
        'B) Your boss',
        'C) Non-friends',
        'D) Tagged friends'
      ],
      'answer': 'C) Non-friends',
      'feedback': 'Changing from Public to Friends removes the post from public view instantly.'
    },
    {
      //cluster 2: post control and security
      'scenario': '',
      'question':
          'A stranger screenshot your public post and shares it out of context. How can you prevent this in the future?',
      'options': [
        'A) Make future posts Friends Only or Custom ',
        'B) Report the screenshot',
        'C) Delete your Facebook account',
        'D) Ask them to take it down nicely'
      ],
      'answer': 'A) Make future posts Friends Only or Custom',
      'feedback':
          'Limiting your audience to trusted groups reduces the chances of content misuse. '
    },
  ],
  3: [
    // Interaction on Others' Posts Question
    {
      'scenarioNumber': 1,
      'scenario':
          'Mark comments on a public post made by a friend. Later, the friend turns on “Review Comments”, which means all comments need approval before appearing.',
      'question': 'What happens to Mark’s comment after the setting is on?',
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
      //cluster 1: privacy control & engagement
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
      'feedback': 'Reactions follow post privacy. If the post is limited, only selected friends can see your interaction.'
    },
    {
      'scenario': '',
      'question': 'What happens to a reply if the original comment is hidden?',
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
      //cluster 2 - changing post & comment privacy
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
      'feedback': 'When changed to “Only Me,” even comments from others are hidden from everyone else.'
    },
    {
      'scenario': '',
      'question':
          'A user comments on a "Friends Only post". The post is now made Public. Who can see the comment?',
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
    // Tag and Review Settings Question
    {
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
      'answer': 'A) Tags stay hidden',
      'feedback':
          'With Tag Review on, tags stay hidden until approved—even if there\'s a delay. '
    },
    {
      //cluster 1: tag approval & removal
      'scenario':
          '',
      'question': 'What happens if Tag Review is turneed off?',
      'options': [
        'A) Tags are hidden by default',
        'B) Tags require approval',
        'C) Tags appear instantly',
        'D) Tags disappear after 24 hours'
      ],
      'answer': 'C) Tags appear instantly',
      'feedback': 'Without Tag Review, tags go live immediately and show up on your profile.'
    },
    {
      'scenario':
          '',
      'question':
          'If Sophie removes a tag from a post, who can still see the post?',
      'options': [
        'A) Shared audience',
        'B) Only Sophie',
        'C) Tagged friends only',
        'D) No one'
      ],
      'answer': 'A) Shared audience',
      'feedback':
          'Removing a tag just unlinks your name—it doesn’t delete or hide the post. '
    },
    {
      //cluster 2: tag privacy & blocking
      'scenario': '',
      'question': 'What happens to tags when you block someone?',
      'options': [
        'A) Tags are removed, post stays',
        'B) Tags remain visible',
        'C) Only mutual friends see them',
        'D) The post is deleted'
      ],
      'answer': 'A) Tags are removed, post stays',
      'feedback': 'When you block someone, existing tags involving them are removed, but the post itself remains.'
    },
    {
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
          'Tags follow the post\'s privacy settings. If a post becomes private, the tag will also be hidden from others. '
    },
  ],
};