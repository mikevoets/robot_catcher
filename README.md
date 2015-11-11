# RobotCatcher

RobotCatcher makes your forms smarter and keeps bots away.

## INSTALLATION

Prerequisites:
+ Ruby (built with for example rbenv and ruby-build)
+ Bundle
+ A Rails application (Rails 3.2.22)

Installation is simple! Add this line to your application's Gemfile:

    gem 'robot_catcher', git: 'git://github.com/mikevoets/robot_catcher.git'

After running `bundle install`, RobotCatcher's functionality will be available in your 
project.

## DESCRIPTION

**RobotCatcher** is a small form plugin that uses several kinds of hashing to
consider whether a form has been filled out by a bot or a human being. 

## HOW TO USE

### Front-end (in your .html.erb document)

In any forms in your Rails application. Instead of `form_for`, use `rc_form_for`, 
and specify the request ip address as an argument (typically `request.remote_ip`:

    rc_form_for(@article, ip: request.remote_ip) do |f|
        f.label 'title'
        f.text_field 'title'

        f.label 'text'
        f.text_area 'text'

        f.submit
    end

Idem dito in case you want to use `form_tag` or anyother field `*_tag`:

    rc_form_tag('/articles', ip: request.remote_ip) do
        label_tag 'title'
        rc_text_field_tag 'title'

        label_tag 'text'
        rc_text_area_tag 'text'
    
        submit_tag
    end

NB: In case of tags, only use tags helper methods on fields (i.e. not on 
labels or submit).

### Back-end

#### In the model

To specify the attributes that should be investigated by the robot catcher,
use the class method `robot_catch`. See the example below. A prerequisite 
is that the model class is a child of ActiveRecord::Base.

    class Article < ActiveRecord::Base
		robot_catch :title, :text
	end

#### In the controller

In the current version, catching robots is done by using the `robot?` method on
a model object. The arguments are the **original** params hash 
(technically a ActionController::Parameters instance), and the request ip address. 
It be the original params hash because that hash contains the information (i.e. 
spinner, timestamp, etc.) that the robot catcher checks. See the example below. 

	def create
	    @article = Article.new(params[:article])

	    if @article.robot?(params, request.remote_ip)
	      redirect_to @article, notice: 'Stupid robot.'
	      return
	    end

	    if @article.save
	      redirect_to @article, notice: 'Article was successfully created.'
	    else
	      render :new
	    end
  	end

NB: This requires some knowledge about the difference between what `rc_form_for`
and `rc_form_tag` generates. As for in the example given in the front-end section 
with `rc_form_tag`, the params hash will include no `:article` key, so a new 
article object is made by passing in the *raw* `params` hash (since this contains 
the right attribute keys and values). Anyway, if you want to do it the Rails way,
use `rc_form_for` like in the example above.

## UPCOMING NEXT
+ Store robot catches in database
+ Configuration (e.g. for a secret that is used for hashing)
+ More [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself "Don't Repeat Yourself")

### To be considered
+ Random order on spinner hasher
+ Support for more tags
+ Integration into native validations
+ Rewriting native form helper class

This project uses MIT-LICENSE.