# TODOs, MAYBE #
* separate view and logic in UI js. 
* Don't use stupid connection per request to redis
* Persistence should be rewritten with a git-esque "shapshot" model:
  Node data that usually stays constant for a long time (run list, roles, recipes)
  should be normalized in the db so we can store lots.
* Job queue for dispatching notifications. Probably use resque. OTOH, you could just write a handler for chef.
