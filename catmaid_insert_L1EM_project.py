from django.core.management.base import NoArgsCommand, CommandError
from optparse import make_option
from django.core.management import call_command

from catmaid.models import *
from catmaid.fields import *

class Command(NoArgsCommand):
    help = "Create L1EM project in CATMAID"

    option_list = NoArgsCommand.option_list + (
        make_option('--user', dest='user_id', help='The ID of the project to setup tracing for'),
        )

    def handle_noargs(self, **options):

        if not options['user_id']:
            raise CommandError, "You must specify a user ID with --user"

        user = User.objects.get(pk=options['user_id'])

        projects = {'Drosophila Larval EM L1': {'stacks': []}}

        # Define the details of a stack the project:

        projects['Drosophila Larval EM L1']['stacks'].append(
            {'title': 'acardona_0111_8',
             'dimension': Integer3D(32768,32768,4840),
             'resolution': Double3D(1.0,1.0,1.0),
             'num_zoom_levels': 6,
             'image_base': '/tiles/0111-8/',
             'comment': '''<p></p>''',
             'trakem2_project': False})

        # Remove example Projects:
        Project.objects.exclude(title='Default Project')
        Project.objects.exclude(title='Evaluation data set')
        Project.objects.exclude(title='Focussed Ion Beam (FIB)')
        
        # Make sure that project and its stacks exist, and are
        # linked via ProjectStack:

        for project_title in projects:
            project_object, _ = Project.objects.get_or_create(
                title=project_title,
                public=True)
            for stack_dict in projects[project_title]['stacks']:
                try:
                    stack = Stack.objects.get(
                        title=stack_dict['title'],
                        image_base=stack_dict['image_base'])
                except Stack.DoesNotExist:
                    stack = Stack(**stack_dict)
                    stack.save()
                ProjectStack.objects.get_or_create(
                    project=project_object,
                    stack=stack)
            projects[project_title]['project_object'] = project_object

        # Also set up the FIB project for tracing with treelines:

        tracing_project = projects['Focussed Ion Beam (FIB)']['project_object']

        call_command('catmaid_setup_tracing_for_project',
                     project_id=tracing_project.id,
                     user_id=user.id)
