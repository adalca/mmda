function default(varargin)
% method from http://dorophone.blogspot.com/2008/03/creating-simple-macros-in-matlab.html

    wb = 1;
    wa = 1;
    vstr = [varargin{:} ';'];
    ii = find(vstr=='=');
    vstr = [vstr(1:ii(1)) '1;'];
    wb = who;
    eval(vstr);
    wa = who;
    v = setdiff(wa,wb);
    str = [ '' ...
    'if ~exist(''%s'', ''var''),'...
    '  %s;,'...
    'end'];
%     varargin{:};
    str = sprintf(str,v{1},[varargin{:}]);
    evalin('caller', str);
    
    
  
% copy of blog entry.    
% 
% Creating Simple Macros in Matlab
% Perhaps this is inadvisable but I recently found it useful to create
% simple macros in Matlab. Matlab does not encourage this behavior but it
% is technically possible, although somewhat ugly. As we shall see, there
% are some interesting things about the way I chose to implement them which
% might inform thinking about other macro systems in other languages. The
% Problem (as always): Tedium The issue is that I frequently find myself
% implementing functions with optional parameters. This necessitates some
% code that looks like this:
% 
% function x=increment(val,amount) % X=INCREMENT(VAL) increments val by one
% % X=INCREMENT(VAL,AMOUNT) increments val by AMOUNT %    AMOUNT defaults
% to 1 if left off; if ~exist('amount')
%    amount = 1;
% end
% 
% x = val + amount;
% 
% 
% Which is fine. Except I find myself implementing lots of optional
% argument functions, frequently with many optional arguments, which means
% writing A LOT of if ~exist(str)... statements. In LISP, God bless it,
% this could be abstracted away with a simple macro (except that you can do
% it with defun so why bother) but in Matlab we have to do cartwheels to
% save keystrokes. Our salvation is that modern Matlab treats function
% calls without parenthesis as special. Consider the function function r =
% f(varargin) r = varagin; Then >> f(1, 2, 3) % -> {1,2,3} %but >> f 1 2 3
% % -> {'1','2','3'} Which means Matlab "quotes" the arguments before
% passing them to the function. We can exploit this and Matlab's evalin
% function to evaluate the arguments selectively in the scope calling a
% function, rather than the function's scope itself. (For those readers not
% familiar with Matlab, its neither dynamically nor lexically scoped.
% Different functions have different scopes, but you can examine the
% enclosing dynamic scope with some functions.) Getting right to business
% define the function default in the following way: function
% default(varargin)
% 
% wb = 1; wa = 1; vstr = [varargin{:} ';']; ii = find(vstr=='='); vstr =
% [vstr(1:ii(1)) '1;']; wb = who; eval(vstr); wa = who; v = setdiff(wa,wb);
% 
% str = [ '' ... 'if ~exist(''%s''),'... '  %s;,'... 'end']; varargin{:}
% str = sprintf(str,v{1},[varargin{:}]); evalin('caller', str); Bear with
% mere here - some fancy trickery is going on. First, a roadmap - we are
% going to figure out the name of the variable whose value we want to
% declare a default for by evaluating a modified form of the passed in
% expression in the current function's scope. This will allow us to figure
% out the variable name by exploiting the Matlab parser. This way even
% complex initializations like x(1) = 10 can be parsed. Next we will
% construct a string to be executed in the scope of the calling function
% which tests for the existence of the variable and, if it does not exist,
% executes the definition passed into the default function. Because I am
% lazy, the code looks a bit mad - but its the quickest way to implement
% this and also likely the smartest.
% 
% So wa and wb simply initialize values so that who reports them when we
% use it later. vstr simply replaces everything after the = input
% expression (merged into one string in the previous line) with a 1. We
% then record the list of symbols with the who statement, eval the vstr and
% record the list again, and finally apply the setdiff function to get only
% the new value, which should be the name we are looking for. Woe be to the
% user who passes in multiple expressions. They will be ignored.
% 
% Now that we know our variable name, we can construct the string to be
% evaluated in the caller. The expression varargin{:} just concatenates all
% the arguments passed in into one string. We finally use an evalin
% expression to insert our macro code into the calling context, roughly.
% 
% Now we can test it out on the command line:
% 
% >> default x = 10 >> x
%    x = 10
% >> clear x >> x = 121 >> default x = 0 >> x
%    x = 121
% Voila! We can now employ this cute little macro in our functions and save
% ourselves a bit of time while more clearly expressing our intent.
% 
% One more note: Matlab passes everything except a trailing ; to the
% function as strings. This makes it hard to remove the parenthesis at the
% default declaration to cause Matlab to output the value. Since you can
% never pass a trailing parenthesis to the macro, the only solution is to
% create a separate macro called pdefault which prints its evaluation. I
% leave this as an exercise for the reader. I find this interesting because
% of the way Matlab segregates its scopes. I have to explicitly request
% values from the scope above me and explicitly evaluate things there. This
% makes it easy to separate the logic of the macro from the results of the
% macro. I wonder why no Lisps do it this way. Macros are sort of like
% functions with quoted arguments and access to their dynamic, rather than
% lexical scope. Why not formalize in this direction rather than formalize
% in the Scheme direction? Anyone know? Posted by J.V. Toups at 12:51 PM