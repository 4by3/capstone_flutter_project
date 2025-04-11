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
          'You’ve just landed an exciting new job! You want to post the news on Facebook—but only your professional network should see it. You don’t want your family or some close friends to know just yet. Time to use your privacy powers.',
      'question':
          'You share a post with a few contacts using Custom. One shares it—who can see it now?',
      'options': [
        'A) Only your contacts',
        'B) The sharer’s followers',
        'C) Mutual friends',
        'D) No one'
      ],
      'answer': 'B) The sharer’s followers',
      'feedback':
          'Shared posts follow their settings—more people might see it.'
    },
    {
      //cluster 1: Privacy control & selective sharing
      //level 2 - hide from a few
      'scenarioNumber': 1,
      'scenario':
          'You’ve just landed an exciting new job! You want to post the news on Facebook—but only your professional network should see it. You don’t want your family or some close friends to know just yet. Time to use your privacy powers.',
      'question':
          'Which setting lets you post something but hide it from specific friends?',
      'options': [
        'A) Public',
        'B) Friends',
        'C) Friends Except…',
        'D) Only Me'
      ],
      'answer': 'C) Friends Except…',
      'feedback': 'This setting allows you to exclude specific friends from seeing your post.'
    },
    {
      //level 3 - full control
      'scenarioNumber': 1,
      'scenario':
          'You’ve just landed an exciting new job! You want to post the news on Facebook—but only your professional network should see it. You don’t want your family or some close friends to know just yet. Time to use your privacy powers.',
      'question': 'What does Custom let you do?',
      'options': [
        'A) All friends',
        'B) Block all',
        'C) Pick who sees',
        'D) Auto-delete'
      ],
      'answer': 'C) Pick who sees',
      'feedback':
          'Friends Except… hides from some. Custom lets you choose exactly who sees it.'
    },
    {
      //cluster 2: changing privacy & post visibility
      //level 2 - changing your mind
      'scenario': '',
      'question':
          'You change a post from Public to Friends. Who loses access?',
      'options': [
        'A) No one',
        'B) Only new viewers',
        'C) Non-friends',
        'D) Everyone'
      ],
      'answer': 'C) Non-friends',
      'feedback': 'Non-friends lose access when you change the post to Friends.'
    },
    {
      //level 3 - tags and shares
      'scenario': '',
      'question':
          'A user sets a post to Friends, but a tagged friend shares it publicly. Who can see the post?',
      'options': [
        'A) Only the tagged friend',
        'B) Only mutual friends',
        'C) Everyone',
        'D) No one'
      ],
      'answer': 'B) Only mutual friends',
      'feedback':
          'Changing to Friends hides the post from non-friends—even if it’s shared publicly.'
    },
  ],
  3: [
    // Interaction on Others' Posts Question
    {
      //level 1 - comment under review
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
      //level 2 - Who Sees the Like?
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
      'feedback': 'Reactions follow the post’s privacy settings.'
    },
    {
      //level 3 - hidden chain reaction
      'scenario': '',
      'question': 'What happens to a reply if the original comment is hidden?',
      'options': [
        'A) Reply disappears',
        'B) Reply stays',
        'C) Becomes a new post',
        'D) Only hidden from commenter'
      ],
      'answer': 'A) Reply disappears',
      'feedback':
          'Likes and replies follow the post’s privacy. Hidden posts hide all interactions.'
    },
    {
      //cluster 2 - changing post & comment privacy
      //level 2 - post locked down
      'scenario': '',
      'question':
          'A user changes a post from "Friends Only" to "Only Me." What happens to a friend’s comment?',
      'options': [
        'A) Still visible to commenter',
        'B) Deleted',
        'C) Only poster sees it',
        'D) Moved to archive'
      ],
      'answer': 'C) Only poster sees it',
      'feedback': 'Only the poster can see comments when the post is set to "Only Me."'
    },
    {
      //level 3 - going public
      'scenario': '',
      'question':
          'A user comments on a Friends Only post. The post is now made Public. Who can see the comment?',
      'options': [
        'A) Everyone',
        'B) No one',
        'C) Only to mutual friends',
        'D) Only with approval'
      ],
      'answer': 'A) Everyone',
      'feedback':
          'Change visibility, and comments follow. "Only Me" hides all, Public shows all.'
    },
  ],
  4: [
    // Tag and Review Settings Question
    {
      'scenarioNumber': 1,
      'scenario':
          'Sophie goes to a party, and a friend uploads a bunch of photos, tagging her in several of them. Luckily, Sophie has Tag Review turned on—so she can approve or decline tags before they appear on her profile. But Sophie doesn’t check for hours.',
      'question': 'What happens to the tagged photos?',
      'options': [
        'A) Tags stay hidden',
        'B) Tags auto-approve',
        'C) Photos disappear',
        'D) Friends can’t see them'
      ],
      'answer': 'A) Tags stay hidden',
      'feedback':
          'With Tag Review on, tags stay hidden until approved, even if delayed.'
    },
    {
      //cluster 1: tag approval & removal
      //level 2 - no gatekeeper
      'scenarioNumber': 1,
      'scenario':
          'Sophie goes to a party, and a friend uploads a bunch of photos, tagging her in several of them. Luckily, Sophie has Tag Review turned on—so she can approve or decline tags before they appear on her profile. But Sophie doesn’t check for hours.',
      'question': 'What happens if Tag Review is disabled?',
      'options': [
        'A) Tags appear instantly',
        'B) Tags require approval',
        'C) Tags are hidden by default',
        'D) Tags disappear after 24 hours'
      ],
      'answer': 'A) Tags appear instantly',
      'feedback': 'Without Tag Review, tags go live immediately.'
    },
    {
      //level 3 - remove the label
      'scenarioNumber': 1,
      'scenario':
          'Sophie goes to a party, and a friend uploads a bunch of photos, tagging her in several of them. Luckily, Sophie has Tag Review turned on—so she can approve or decline tags before they appear on her profile. But Sophie doesn’t check for hours.',
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
          'Without Tag Review, tags go live. Removing a tag just unlinks you—it won’t delete the post.'
    },
    {
      //cluster 2: tag privacy & blocking
      //level 2 - block & wipe
      'scenario': '',
      'question': 'What happens to tags when you block someone?',
      'options': [
        'A) Tags are removed, post stays',
        'B) Tags remain visible',
        'C) Only mutual friends see them',
        'D) The post is deleted'
      ],
      'answer': 'A) Tags are removed, post stays',
      'feedback': 'Blocking removes tags but the post remains for others.'
    },
    {
      //level 3 - privacy change
      'scenario': '',
      'question':
          'If a post’s privacy is changed after tagging, what happens to the tag?',
      'options': [
        'A) Follows new privacy settings',
        'B) Stays as originally set',
        'C) Becomes hidden',
        'D) Tag is removed'
      ],
      'answer': 'A) Follows new privacy settings',
      'feedback':
          'Blocking removes tags and interactions. Tags follow post privacy unless removed.'
    },
  ],
};