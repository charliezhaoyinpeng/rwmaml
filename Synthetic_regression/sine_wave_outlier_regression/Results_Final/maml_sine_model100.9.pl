��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_data
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_data.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2129342426528qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2128726865920qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2128726868128qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2128726870336q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2128726866016q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2128726868800q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2128726865920qX   2128726866016qX   2128726868128qX   2128726868800qX   2128726870336qX   2129342426528qe.(       P%�>�N��D�b? ?��=`I?0�h>�K����!�-�y>�?Ӗ]?�@?�6�>緋��]>��.>�'?���s��>�?��Z����<���>'�@?(�к��S>x鿀�ſ�?]X����Q?z���2�=�l?��?-�<�e�qb��/?��(       ��v����="w>=�H>>�Ծ+��@Qu��|+��N?��b�]~��OR�i6���>�7��L�>���<ܤ?�'ʾ ����$���J>	w�<�F.?��)?M���-��=�_��;Y˼�2>�@1��/���m��d=�ӿ<�>��+Û�p��=X����@      ��	>`���7!���̟�=����m�-�����3{ɽL�u�P�y����� n��S<½�=~[�=�������iY��z&P�<�[��мg��:��=B����AM=��G��]�����ޜ�H�"����_.�� l��i=��>�g���Km�"�)������{ ��D�="%��l��%O�
���B�S�Nf�=r7��M��熾�Wѽ��_�7���Or���zý�
�A�>Ӂ,�����¼Y������s�	�7�H���ҭ�=� >��Ľ�
=��м�Q�����	Y�K
��䉾 b;�>��g=��齪��>9�=������<�=�>�8ڿR{y��н�޾s�4>�s->H�y�i�<SGԾ�;<���"��Ǿ2�>�.�`��Z����
>�j�<�C��g)�=4M??D��>��R�O�>�R]�*N|�d"k=R��?�}�/"=V�P?o�^?0�?})��X�ɽ)�Ld9?=����U>D�ÿ�����ͼF���f�=�o���Ӥ�]P;�N���s�=:�_=��W?�'־��@>� ѿ<�ݽ��|��	$>x<;�˽-�<�,�����M
?~���( ?��\<y��:�m?����N����)Q��CV���2ֽdĥ����d��?��=��8�T���#8f=� 
�[���Qk�t�⾬�Z��7�[]���=~����c�>H�>G�=ߠ��M���q�>��=۞��m��j�A>��%�Ƿ�=��/>5��=rg�>��ƽ�O����=Ӷ,����I����]���/>`���D[r��N�=9��=��Ƚ`�����L�LO�=δ�6��Q�����
xl�]����7���<�yM=P�g����=�om��\����=�Fμ�\u�É<�->E���W��xm=���=׀��V��(��=Y�۸�=��)�������;�~n=h	X>��p��>��e��9V�����	O?�0�)���+1���41�D�>��>�E9��S}=d3���E���x� 9%�{ߊ��g��"����ps=���>������=���k&���V<&���&����S�߼v����>��E��탾�6��x|�	L����=s��A������i����=F�h��mU���3�]?h�Ou�����/s=̌ἤx����<X� �P/���Y��^=��ｈ|ڽB����p;�Io�����-����.�;�H>e�h�<���t�K�N����M�C=�_��޳�;i\U�����-��)r)�;M�>,W[?��@�l��zm�?�f��v���3��7O콄��?o�8>.��=�陿�����/�⿡,�>��=�����<�t���'@�v���D>lg����y?7枿%h��"�>����>�S��w�����:	��^h����)�'���⳾˩�B?Y&����h����>��>�����q�w�پQ䂾\Eh?{��>|U��ͽnKѾ��D�̎�;T�'��P=.�����=֧&��_���3�>(��!��x0=�����ļ��X>���XQc�|Up?q&=����3��smt?q�^��i������?�J�>�s��-�1?��?��q��ؤ��O=|�-=N�m>�]�<��Z��\��
���H���u�;���������}�>">�
o�/=�n����>�t>�i�0�M2�=��<�������w�ǿ�䁾�fѾ���=��=�9���I����=�������j�=���R� ��U�=�p�!l	<�� >&%=�<���=�>nb����=3���P�P�����=�O�p���E����=�r=F��=��=�Ȱ=����ҡ<�=���=F� f,�P�=dBX=�sߺN��3?�b��b��>�-��	�!�=�r=OL ?<�A���aG�k�*�t�?���>b۽V3���ˊ>�!w=�߾J�f��F�=�H����<6��>0�e=���>��*齌�����׾�s��V⓾�+��{�#�B�'��?�1b���I��䧾p~���v��J�:>1�v=��>�9�<��=�����
�����s�o����=��F�~N�����=}�{��?&>�2��Ҿ�B�Z*>��`� =�0���O>���=�Z�1S/���.?g��>hK)��K�>�-��@y��=��p?��ְ@<;�U?]�?���>�2��U���n>�oÿ)��v�`�T�m?�Pm�Z.��[��EC�d(?.0?�(���b�LZ����gmN��J�j򻻸�=z}�=�8�mA����>�5�G��Og�	���T})��� �UT�<��$=<�ں�=o�^<�~�OEt�0�?Vо��0=ǌ�?�f�<зƼH�=�k|>f�ǿ5zҾ�v{�bT�l��>��x=��
�a��=.�Ⱦ�&���=�����5�}Z&=�R־��\<�G���C>>>�`��:��s�-<�ɇ?Da>:^�B�>�y���¾^!��ҋ?FⱾ�q"���?_�9?"�>�p2=�K=���1F=��<˾=� ˽H���0D����b�;�7�x�缜��=��`����p"=���BZ�!߯�h�=��(=Q!�����g�|��+5�
��ȡ���I�s���B��=pys=��"��f=o�9�+����������ҽ�Y�<�G�>"��=H��Z�ѿ(u>1��9=?�}�����>��Q>5!׾����g���nO�
6?�K�>� >�*?4�=�A�N�>�̈=���?��;�.�v&>H��O����b-�·0?�Z�����'�?�<>t�?a��>?[l>ND���W-��=�	Su���ݽ�^?�"/>IG����?�U�?�OC<�����y�;��G>�8>�� >^�f��6��G�a��O��싅��>���-�p��<ΐ�=w�1�=�R��8>ST��z��>��=����wk=!U?�r#�=�(Q�w�Ѿ��ֿ��3�
_2�«=>4�[�k�>VyV�R��=��u弩��=@�=��ڽln��faƼi��^TF���d���7���>=� {���L����Q��<�d=j���ԽU��-����%e�^�=d�1���x=�IC�J���k-=ک@��v���ӑ���C�Lٷ=�xM���^=�����=��?&F?:��>��7��t?���?�W?�tN���E)9�?�<Dǲ>V0Ӿ��νM6Ծ�� ���<��g��Ӿ�J�k����P��km���<SM���>�1{>��=&�=����/>��ڽ��'��ԿC;��B{�R�>?�9>Wɂ��,">��:�d>{��>$]J��,>И�A�����=`a��>F>Ȏ
���ھ�������=�D�<�>MV�>��Ǿk\&>]�)����=�b����o�1�ȇ-�d��<��_�(�̡=2�Ѿo�<��<FC>�^�?�r?���߼� �=vi��`��B9��� >1���A�h��=q(m������C�������P�O������=τ���=����	�;�����J>�-��س�����A=k�����=A>��/���ֺ�E׽�_�=�3�P���	���M�.��=�_O��0= �B=��F���9޿o��>mE0>���?�˾�B?�\e?
{2��r^�%�׆@˜�.6�=�ش�	.�.ar�J��Zܥ;��U�f��=#�� I~<Fo�>r+�>��<�2�� >?�!>Q��"=��K���1>\T������(]�qU���(.��|�>������w����g����=g�?��I>~C��:��\Y=������I>��=�R��`�<Ưսo�>Ml�<U��?��;�=�s
�"��=XX��4^�=�ʁ<��:N�>Γ��̧���^>yۘ��wE?����x�	:\vh?�z���нEÒ�GƔ�����@V�D�=�8=��v=�[�;���#�o'�=�楼�?��W�<|Y�ni��;=�Ҽ�2g�a�=�`������$���StA�'ʓ��ཟ�x�Uq�=�����7��.=����~<�ݽ�;���j��>7=b6�=�u�<^���u>�T�;�9�8',�3�=%���_);�P)�=�� >�'�X0��;��@��<�@�=8�߽/�ڽ��=���=`޻��`Ҏ�B��=��Z �>��V�/r��Jc:��,����%C5�.c7��x�=K�>q��[��x�'�vh��;����=�j=u��%��=%ED��YW�-)�>ʹ	?����e�-S�?>1f={ܘ�<O7=A���G0>'e�>q��O�������������<H�(��{���a�=[���9<�֦j���W>oB�u�>%�=����<=F��>q!������鶿���������>��4�=���>�����=0�?E���
Լ_��=�턼2��=��ֽ�-��(s��Wa�Q��#c=�>;��ZU���=�<!��*������=9���]�=*�	�m���ȺF�*^-�&$'������<ԕ��a�<��ܽFR�<��ǽ2��=���gN=�Q>�J6�G�9=�CD�Z�=����^���̾�O=�3p���)�q�M��W>��>��<�$>���>w־'U�=�!�����4��ȋ޽�>��?3�=6���>p��gپ���?#缾�3%�Z�8?��2>��?����y�<��≾�j����
=��=�������<�A7�-A��@=��T=��b=�C��ˤ��=�RC���=c8���P�jX����:��Jz�o�޽��p�2��08�WH�(��<� i=�����=�ٸ��k�;�x����b��� )v: Cu����� �<�^>$i=�?��:�C�?)�(?�L��A^=%�?i��<�˾t"�<�08�Tu>�i�>f Ѿ���3� �s�Ͼ/�.� ��P��b(>(0�Ŧ���۾N>1�*��>�U��>ؽ��Y<�Ư:ƛ𼦙󽯥����>u+��������	�Y�V��;�bD<l���?�G�>8/0>?&3>�at��h�=� �=5��>����!9���a=a�㽮O�t��=�v��U⪽?�>< =G>�>��=���Ǘ<��d>���'�;�ݿ�w�=����\����=X��LE�@M>3+����J�6z彄Y�'�>�P��-��dY#=
4�=P���D}���<y� ��Ҥ*�Zgy��,�:3�>fa�=P���^�x𝽲խ��#J�:��=t�=�T=��~�"��=*ĳ<����W���X���Y��с�du��(�㽎L��,�i�A����~�O��f�X:O�uJ>[V���[��!Խ��X<�g�@�R��S��>�9�;h9��<l�?���>=(�+��=� ƽc���7�=<�{�!����Q���Խ�1H��M#==&��8g�<`���J�3��p�����,�"�U�Z��r�=�����A ��>��/<-l>CA���a�]����=����(�X=&Jh�v+�=s���k;<[�X<��c� �*:����>�
���� �Pk>�	��5����}GO�m���=�O�n��_����*d�o"��M!.�~�n�<ѽ����T��-�z�P��0N��E�x��<���=�&���=�X�z?�^?�eT��0?A�_?����ξ�q�=���>��>�1s=��þ��e�w���|ݾi݆�	k�<h����sN����
���N<2�> V��W(z>�~i=9��=z�">ۧ&��'=s�g�aH۾7�$�<�!�4�r>S�:>�v�<�c��BV�M�n�;}֨��=Z=�.���=p�*}=8l�;b:�6����ƻ��1= ^�����i�<���Y>��w% >і�<�G;t��=��=X� �Xݛ=�o���&�� ==.�e<B�9�����'�%��<�P׽q�<=�@��轩�a<%���u���h�?j���rơ�D���'u�=<�=t΢��w}�'��A4������t�>Y�>�l���>���>>$">�q<�;�=�=6?���=nʍ�tp�<�8>�F�=5��=��ٽ��\>x�N>о>xg�<!wӼ'3;�}��L?x��!�=�#K>�~����6:]?�3�>�c��?��?R��Qо����G =s�M>á�=K�;���׽�u��a䅿 ���<؃�Ӽ��f�=!8>򥣾�&h���*>_1�����>/�>C����=�=M+j=Jj���1���q5�s�ֿ�����4�)(|>=��=�<�       �8�(       P2�����=�H�;Xcs=�e*�e3�>�!����>Kd?�4=��3?�s"�/S�>�>���KXV�����d=D����\����?�d'> M�<��W=�5���+�еv��U}����=��<��X�|����X����B�J�$��T	��(       ��>�^4� p�>�N"����>��>f��yj�d��>ʉ����>�d;�Bۼޜ�>!�"?G��>`J�>��^�/PS� �?/�"����{�=!t�>���??���;�\(��(��C��ds�""2��|'?4a�>���=B���G�{>�/4�2���O;�