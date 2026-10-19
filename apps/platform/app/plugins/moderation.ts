import { AccessViewModel } from '#shared/features/moderation/presentation/access_view_model';
import { HttpModerationRepository } from '#shared/features/moderation/data/http_moderation_repository';
import { AccessModeration,ReviewReports,DecideReport } from '#shared/features/moderation/domain/moderation';
import { ModerationViewModel } from '#shared/features/moderation/presentation/moderation_view_model';
export default defineNuxtPlugin(()=>({provide:{reviewerAccessModel:()=>new AccessViewModel(new AccessModeration(new HttpModerationRepository())),moderationModel:()=>{
  const repository=new HttpModerationRepository();
  return new ModerationViewModel(new AccessModeration(repository),new ReviewReports(repository),new DecideReport(repository),()=>crypto.randomUUID());
}}}));
